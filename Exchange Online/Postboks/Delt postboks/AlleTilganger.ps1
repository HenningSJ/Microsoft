# KJØR FØRST: Connect-ExchangeOnline

# 1) Sett listen med postbokser du vil sjekke:
$mailboxes = @(
    "nnkm@nnkm.no",
    "foto@nnkm.no",
    "produksjonskalender@nnkm.no",
    "stilling@nnkm.no",
    "venn@nnkm.no",
    "hanne@nnkm.no",
    "direktor@nnkm.no",
    "handle@nnkm.no",
    "lonn@nnkm.no",
    "oystein@nnkm.no",
    "persondata@nnkm.no",
    "presse@nnkm.no",
    "skape@nnkm.no",
    "to@nnkm.no"
)

# 2) Filtrer bort systemkontoer i rapporten
$skip = 'NT AUTHORITY|S-1-5-|DiscoverySearchMailbox|FederatedEmail|Migration|SystemMailbox'

# 3) Cache for mottakere (ytelse)
$RecipientCache = @{}
function Get-RecipientCached {
    param([Parameter(Mandatory)][string]$Identity)
    if ($RecipientCache.ContainsKey($Identity)) { return $RecipientCache[$Identity] }
    try { $r = Get-Recipient -Identity $Identity -ErrorAction Stop } catch { $r = $null }
    $RecipientCache[$Identity] = $r
    return $r
}

# 4) Løs grupper rekursivt (DG/UDG/USG + M365-grupper) til sluttbrukere (SMTP)
function Resolve-GroupMembersRecursive {
    param([Parameter(Mandatory)][string]$Identity, [hashtable]$Cache = $(New-Object hashtable))
    if ($Cache.ContainsKey($Identity)) { return $Cache[$Identity] }

    $resolved = @()
    $rec = Get-RecipientCached -Identity $Identity
    if (-not $rec) { $Cache[$Identity] = @(); return @() }

    switch -Regex ($rec.RecipientTypeDetails) {
        '^(MailUniversalSecurityGroup|MailUniversalDistributionGroup|UniversalSecurityGroup|UniversalDistributionGroup)$' {
            $members = Get-DistributionGroupMember -Identity $rec.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue
            foreach ($m in $members) {
                if ($m.RecipientTypeDetails -match 'UserMailbox|SharedMailbox|LinkedMailbox|RoomMailbox|EquipmentMailbox') {
                    $resolved += @($m.PrimarySmtpAddress ?? $m.Name)
                } elseif ($m.RecipientTypeDetails -like '*Group*') {
                    $resolved += (Resolve-GroupMembersRecursive -Identity $m.Identity -Cache $Cache)
                }
            }
        }
        '^GroupMailbox$' { # Microsoft 365 Group
            $gm = @()
            try { $gm += Get-UnifiedGroupLinks -Identity $rec.Identity -LinkType Members -ResultSize Unlimited -ErrorAction Stop } catch {}
            try { $gm += Get-UnifiedGroupLinks -Identity $rec.Identity -LinkType Owners  -ResultSize Unlimited -ErrorAction SilentlyContinue } catch {}
            foreach ($m in $gm) {
                if ($m.PrimarySmtpAddress) { $resolved += @($m.PrimarySmtpAddress) }
                elseif ($m.Name)          { $resolved += @($m.Name) }
            }
        }
        default {
            $resolved += @($rec.PrimarySmtpAddress ?? $rec.Name)
        }
    }

    $resolved = $resolved | Sort-Object -Unique
    $Cache[$Identity] = $resolved
    return $resolved
}

function Resolve-PrincipalToUsers {
    param([Parameter(Mandatory)][string]$Principal, [hashtable]$Cache)
    $rec = Get-RecipientCached -Identity $Principal
    if ($rec -and $rec.RecipientTypeDetails -like '*Group*') {
        return (Resolve-GroupMembersRecursive -Identity $rec.Identity -Cache $Cache)
    } elseif ($rec) {
        return @($rec.PrimarySmtpAddress ?? $rec.Name)
    } else {
        return @()
    }
}

# 5) Bygg normalisert rapport (én rad pr postboks–bruker–tilgang)
$rows = @()
$cache = @{}

foreach ($mbxId in $mailboxes) {

    # Hent mailbox-objektet (for SMTP/visningsnavn og SendOnBehalf)
    try {
        $mbx = Get-EXOMailbox -Identity $mbxId -Properties GrantSendOnBehalfTo -ErrorAction Stop
    } catch {
        Write-Warning "Fant ikke postboks: $mbxId. Hopper over."
        continue
    }
    $name = $mbx.DisplayName
    $smtp = $mbx.PrimarySmtpAddress

    # --- FullAccess ---
    $faPerm = Get-EXOMailboxPermission -Identity $mbx.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue `
             | Where-Object { -not $_.IsInherited -and $_.User -notmatch $skip }
    foreach ($p in $faPerm) {
        $src = $p.User
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $cache
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                AccessType         = 'FullAccess'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }

    # --- SendAs ---
    $saPerm = Get-RecipientPermission -Identity $mbx.Identity -ErrorAction SilentlyContinue `
             | Where-Object { $_.AccessRights -contains 'SendAs' -and $_.Trustee -notmatch $skip }
    foreach ($p in $saPerm) {
        $src = $p.Trustee
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $cache
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                AccessType         = 'SendAs'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }

    # --- SendOnBehalf ---
    $sobPrincipals = @($mbx.GrantSendOnBehalfTo)
    foreach ($src in $sobPrincipals) {
        if ($src -match $skip) { continue }
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $cache
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                AccessType         = 'SendOnBehalf'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }
}

# 6) Eksporter i format som åpner riktig i norsk Excel (semikolon + Unicode)
$path = Join-Path $PWD ("Mailbox_Access_Full_SendAs_OnBehalf_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmm'))
$rows = $rows | Sort-Object MailboxDisplayName, AccessType, User -Unique
$rows | ConvertTo-Csv -NoTypeInformation -Delimiter ';' | Set-Content -Path $path -Encoding Unicode
Write-Host "Ferdig. Rapport: $path"
``