<#
.SYNOPSIS
  Rapporterer tilgang (FullAccess, SendAs, SendOnBehalf) for ALLE delte postbokser i Exchange Online.

.DESCRIPTION
  - Henter alle delte postbokser (SharedMailbox). Valgfritt inkluder inaktive og soft-deleted.
  - Løser grupper rekursivt (DG/UDG/USG) og M365-grupper (GroupMailbox) til sluttbrukere (SMTP).
  - Fjerner system/SID-støy og arvede rettigheter.
  - Eksporterer én rad per postboks med semikolon-separerte brukerlister.

.PARAMETER IncludeInactive
  Inkluder delte postbokser som er inaktive (compliance hold/eDiscovery).

.PARAMETER IncludeSoftDeleted
  Inkluder delte postbokser som er soft-deleted.

.PARAMETER OutputPath
  Full sti til CSV. Default: .\SharedMailbox_Access_YYYYMMDD_HHMM.csv

.EXAMPLE
  Connect-ExchangeOnline
  .\Get-SharedMailboxAccessReport.ps1

.EXAMPLE
  Connect-ExchangeOnline
  .\Get-SharedMailboxAccessReport.ps1 -IncludeInactive -IncludeSoftDeleted -OutputPath C:\Temp\Shared_Access.csv
#>

[CmdletBinding()]
param(
    [switch]$IncludeInactive,
    [switch]$IncludeSoftDeleted,
    [string]$OutputPath = $(Join-Path $PWD ("SharedMailbox_Access_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmm')))
)

Write-Host "Starter … henter delte postbokser og rettigheter." -ForegroundColor Cyan

# ---------- Hjelpefunksjoner ----------
$RecipientCache = @{}

function Get-RecipientCached {
    param([Parameter(Mandatory)] [string] $Identity)
    if ($RecipientCache.ContainsKey($Identity)) { return $RecipientCache[$Identity] }
    try {
        $r = Get-Recipient -Identity $Identity -ErrorAction Stop
        $RecipientCache[$Identity] = $r
        return $r
    } catch {
        $RecipientCache[$Identity] = $null
        return $null
    }
}

function Resolve-GroupMembersRecursive {
    param(
        [Parameter(Mandatory)] [string] $Identity,
        [hashtable] $Cache = $(New-Object hashtable)
    )
    if ($Cache.ContainsKey($Identity)) { return $Cache[$Identity] }

    $resolved = @()
    $group = Get-RecipientCached -Identity $Identity
    if (-not $group) { $Cache[$Identity] = @(); return @() }

    switch -Regex ($group.RecipientTypeDetails) {
        '^(MailUniversalSecurityGroup|MailUniversalDistributionGroup|UniversalSecurityGroup|UniversalDistributionGroup)$' {
            $members = Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue
            foreach ($m in $members) {
                if ($m.RecipientTypeDetails -match 'UserMailbox|SharedMailbox|LinkedMailbox|RoomMailbox|EquipmentMailbox') {
                    $resolved += @($m.PrimarySmtpAddress ?? $m.Name)
                } elseif ($m.RecipientTypeDetails -like '*Group*') {
                    $resolved += (Resolve-GroupMembersRecursive -Identity $m.Identity -Cache $Cache)
                }
            }
        }
        '^GroupMailbox$' {  # Microsoft 365-gruppe
            $gmembers = @()
            try { $gmembers += Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -ResultSize Unlimited -ErrorAction Stop } catch {}
            try { $gmembers += Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Owners  -ResultSize Unlimited -ErrorAction SilentlyContinue } catch {}
            foreach ($m in $gmembers) {
                if ($m.PrimarySmtpAddress) { $resolved += @($m.PrimarySmtpAddress) }
                elseif ($m.Name)          { $resolved += @($m.Name) }
            }
        }
        default {
            $resolved += @($group.PrimarySmtpAddress ?? $group.ExternalEmailAddress ?? $group.Name)
        }
    }

    $resolved = $resolved | Sort-Object -Unique
    $Cache[$Identity] = $resolved
    return $resolved
}

function Resolve-PrincipalToUsers {
    param(
        [Parameter(Mandatory)] [string] $Principal,
        [hashtable] $Cache
    )
    $users = @()
    $rec = Get-RecipientCached -Identity $Principal
    if ($rec -and $rec.RecipientTypeDetails -like '*Group*') {
        $users += (Resolve-GroupMembersRecursive -Identity $rec.Identity -Cache $Cache)
    } elseif ($rec) {
        $users += @($rec.PrimarySmtpAddress ?? $rec.Name)
    }
    return ($users | Sort-Object -Unique)
}

# ---------- Hent ALLE delte postbokser ----------
$active = Get-EXOMailbox -RecipientTypeDetails SharedMailbox -Properties GrantSendOnBehalfTo -ResultSize Unlimited -ErrorAction SilentlyContinue

$inactive = @()
if ($IncludeInactive) {
    try {
        $inactive = Get-Mailbox -InactiveMailboxOnly -ResultSize Unlimited -ErrorAction SilentlyContinue |
                    Where-Object { $_.RecipientTypeDetails -eq 'SharedMailbox' }
    } catch {}
}

$softDeleted = @()
if ($IncludeSoftDeleted) {
    try {
        $softDeleted = Get-Mailbox -SoftDeletedMailbox -ResultSize Unlimited -ErrorAction SilentlyContinue |
                       Where-Object { $_.RecipientTypeDetails -eq 'SharedMailbox' }
    } catch {}
}

$shared = @($active + $inactive + $softDeleted) |
    Group-Object { $_.ExternalDirectoryObjectId ?? $_.ExchangeGuid ?? $_.PrimarySmtpAddress ?? $_.Identity } |
    ForEach-Object { $_.Group | Select-Object -First 1 } |
    Sort-Object DisplayName, PrimarySmtpAddress

Write-Host "Delte postbokser funnet: $($shared.Count) (aktive: $($active.Count), inaktive: $($inactive.Count), soft-deleted: $($softDeleted.Count))" -ForegroundColor DarkGray

# ---------- Bygg rapport (Wide: én rad per postboks) ----------
$skip = 'NT AUTHORITY|S-1-5-|DiscoverySearchMailbox|FederatedEmail|Migration|SystemMailbox'
$rows = @{}
$RecipientCache = @{}  # reset cache for denne kjøringen

$idx = 0
foreach ($mbx in $shared) {
    $idx++
    Write-Host ("[{0}/{1}] {2}" -f $idx, $shared.Count, $mbx.DisplayName) -ForegroundColor Yellow

    $faUsers = @()
    $saUsers = @()
    $sbUsers = @()

    # FullAccess
    try {
        $faPerm = Get-EXOMailboxPermission -Identity $mbx.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue |
                  Where-Object { -not $_.IsInherited -and $_.User -notmatch $skip }
        foreach ($p in $faPerm) {
            $faUsers += (Resolve-PrincipalToUsers -Principal $p.User -Cache $RecipientCache)
        }
    } catch {}

    # SendAs
    try {
        $saPerm = Get-RecipientPermission -Identity $mbx.Identity -ErrorAction SilentlyContinue |
                  Where-Object { $_.AccessRights -contains 'SendAs' -and $_.Trustee -notmatch $skip }
        foreach ($p in $saPerm) {
            $saUsers += (Resolve-PrincipalToUsers -Principal $p.Trustee -Cache $RecipientCache)
        }
    } catch {}

    # SendOnBehalf
    $sobPrincipals = @()
    if ($mbx.PSObject.Properties.Name -contains 'GrantSendOnBehalfTo') {
        $sobPrincipals = @($mbx.GrantSendOnBehalfTo)
    } else {
        try {
            $mbxClassic = Get-Mailbox -Identity $mbx.Identity -ErrorAction Stop
            $sobPrincipals = @($mbxClassic.GrantSendOnBehalfTo)
        } catch { $sobPrincipals = @() }
    }
    foreach ($src in $sobPrincipals) {
        $sbUsers += (Resolve-PrincipalToUsers -Principal $src -Cache $RecipientCache)
    }

    $faUsers = $faUsers | Sort-Object -Unique
    $saUsers = $saUsers | Sort-Object -Unique
    $sbUsers = $sbUsers | Sort-Object -Unique

    $rows[$mbx.PrimarySmtpAddress.ToString().ToLower()] = [pscustomobject]@{
        MailboxDisplayName = $mbx.DisplayName
        PrimarySmtp        = $mbx.PrimarySmtpAddress
        FullAccessUsers    = ($faUsers -join '; ')
        SendAsUsers        = ($saUsers -join '; ')
        SendOnBehalfUsers  = ($sbUsers -join '; ')
    }
}

$export = $rows.Values | Sort-Object MailboxDisplayName
$export | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
Write-Host "Ferdig. Rapport lagret til: $OutputPath" -ForegroundColor Green
``