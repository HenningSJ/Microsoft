<#
.SYNOPSIS
  Rapporterer hvem som har tilgang til alle (valgbare) postbokser i Exchange Online.

.DESCRIPTION
  Henter FullAccess, SendAs og SendOnBehalf for alle postbokser (UserMailbox, SharedMailbox, RoomMailbox, EquipmentMailbox).
  - Løser grupper rekursivt (DG/UDG/USG) med Get-DistributionGroupMember
  - Løser Microsoft 365-grupper (GroupMailbox) med Get-UnifiedGroupLinks (Members/Owners)
  - Fjerner system/SID/NT AUTHORITY, og arvede rettigheter
  - Kan inkludere inaktive og soft-deleted postbokser
  - Eksporterer Normalized (én rad per postboks/bruker/tilgang) eller Wide (én rad per postboks)

.PARAMETER IncludeInactive
  Inkluder inaktive postbokser (på hold/eDiscovery).

.PARAMETER IncludeSoftDeleted
  Inkluder soft-deleted postbokser.

.PARAMETER RecipientTypeDetails
  Hvilke postbokstyper som skal inkluderes (default: UserMailbox, SharedMailbox, RoomMailbox, EquipmentMailbox).
  Eksempler: 'UserMailbox','SharedMailbox','RoomMailbox','EquipmentMailbox','GroupMailbox'

.PARAMETER OutputStyle
  'Normalized' (default) eller 'Wide'.

.PARAMETER OutputPath
  Full sti til CSV. Default: .\Mailbox_Access_YYYYMMDD_HHMM.csv

.EXAMPLE
  Connect-ExchangeOnline
  .\Get-MailboxDelegationsReport.ps1 -OutputStyle Normalized

.EXAMPLE
  Connect-ExchangeOnline
  .\Get-MailboxDelegationsReport.ps1 -IncludeInactive -IncludeSoftDeleted -RecipientTypeDetails UserMailbox,SharedMailbox -OutputStyle Wide
#>

[CmdletBinding()]
param(
    [switch]$IncludeInactive,
    [switch]$IncludeSoftDeleted,

    [string[]]$RecipientTypeDetails = @('UserMailbox','SharedMailbox','RoomMailbox','EquipmentMailbox'),

    [ValidateSet('Normalized','Wide')]
    [string]$OutputStyle = 'Normalized',

    [string]$OutputPath = $(Join-Path $PWD ("Mailbox_Access_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmm')))
)

Write-Host "Starter … henter postbokser og rettigheter." -ForegroundColor Cyan

# ---------- Hjelpefunksjoner ----------

# Cacher mottakere vi slår opp (for ytelse)
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

# Løs opp grupper rekursivt (DG/UDG/USG) og håndter Microsoft 365-grupper (GroupMailbox)
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
        # Klassiske mail-enabled grupper
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

        # Microsoft 365 Group (GroupMailbox)
        '^GroupMailbox$' {
            # Hent medlemmer (og eiere) – eiere kan reelt ha samme tilgang i mange organisasjoner
            $gmembers = @()
            try {
                $gmembers += Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Members -ResultSize Unlimited -ErrorAction Stop
            } catch { }
            try {
                $gmembers += Get-UnifiedGroupLinks -Identity $group.Identity -LinkType Owners -ResultSize Unlimited -ErrorAction SilentlyContinue
            } catch { }

            foreach ($m in $gmembers) {
                # Get-UnifiedGroupLinks returnerer objekter med bl.a. PrimarySmtpAddress
                if ($m.PrimarySmtpAddress) {
                    $resolved += @($m.PrimarySmtpAddress)
                } elseif ($m.Name) {
                    # Fall-back hvis smtp mangler
                    $resolved += @($m.Name)
                }
            }
        }

        default {
            # Ikke en gruppe – returner som "bruker"
            $resolved += @($group.PrimarySmtpAddress ?? $group.ExternalEmailAddress ?? $group.Name)
        }
    }

    # Rydd duplikater
    $resolved = $resolved | Sort-Object -Unique
    $Cache[$Identity] = $resolved
    return $resolved
}

# Løs en principal (bruker/gruppe) til sluttbrukere (SMTP-strenger)
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
    } else {
        # ukjent principal (SID/system) – ignorer
    }

    return ($users | Sort-Object -Unique)
}

# ---------- Hent alle postbokser ----------

# Aktive postbokser (EXO v3) – inkluder ønskede typer
$active = @()
try {
    $active = Get-EXOMailbox -RecipientTypeDetails $RecipientTypeDetails -Properties GrantSendOnBehalfTo -ResultSize Unlimited -ErrorAction Stop
} catch {
    Write-Warning "Get-EXOMailbox feilet delvis. Fortsetter med det som er tilgjengelig."
    $active = Get-EXOMailbox -Properties GrantSendOnBehalfTo -ResultSize Unlimited -ErrorAction SilentlyContinue | Where-Object { $_.RecipientTypeDetails -in $RecipientTypeDetails }
}

# Valgfritt: inaktive og/eller soft-deleted (klassisk Get-Mailbox)
$inactive = @()
$softDeleted = @()

if ($IncludeInactive) {
    try {
        $inactive = Get-Mailbox -InactiveMailboxOnly -ResultSize Unlimited -ErrorAction SilentlyContinue | Where-Object { $_.RecipientTypeDetails -in $RecipientTypeDetails }
    } catch { Write-Verbose "Ingen inaktive funnet eller tilgang mangler." }
}

if ($IncludeSoftDeleted) {
    try {
        $softDeleted = Get-Mailbox -SoftDeletedMailbox -ResultSize Unlimited -ErrorAction SilentlyContinue | Where-Object { $_.RecipientTypeDetails -in $RecipientTypeDetails }
    } catch { Write-Verbose "Ingen soft-deleted funnet eller tilgang mangler." }
}

# Slå sammen og dedupliser
$allMailboxes = @($active + $inactive + $softDeleted) |
    Group-Object { $_.ExternalDirectoryObjectId ?? $_.ExchangeGuid ?? $_.PrimarySmtpAddress ?? $_.Identity } |
    ForEach-Object { $_.Group | Select-Object -First 1 } |
    Sort-Object DisplayName, PrimarySmtpAddress

Write-Host "Postbokser funnet: $($allMailboxes.Count) (aktive: $($active.Count), inaktive: $($inactive.Count), soft-deleted: $($softDeleted.Count))" -ForegroundColor DarkGray

# ---------- Bygg rapport ----------

# Filter bort system/SID‑kontoer i rettighetslistene
$principalSkipPattern = 'NT AUTHORITY|S-1-5-|DiscoverySearchMailbox|FederatedEmail|Migration|SystemMailbox'

$rows = @()

$idx = 0
foreach ($mbx in $allMailboxes) {
    $idx++
    $name = $mbx.DisplayName
    $smtp = $mbx.PrimarySmtpAddress
    $type = $mbx.RecipientTypeDetails

    Write-Host ("[{0}/{1}] {2}" -f $idx, $allMailboxes.Count, $name) -ForegroundColor Yellow

    # --- FullAccess ---
    $faPerm = @()
    try {
        $faPerm = Get-EXOMailboxPermission -Identity $mbx.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue |
                  Where-Object { -not $_.IsInherited -and $_.User -notmatch $principalSkipPattern }
    } catch { }

    foreach ($p in $faPerm) {
        $src = $p.User
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $RecipientCache
        if (-not $users -or $users.Count -eq 0) { continue }
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                RecipientType      = $type
                AccessType         = 'FullAccess'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }

    # --- SendAs ---
    $saPerm = @()
    try {
        $saPerm = Get-RecipientPermission -Identity $mbx.Identity -ErrorAction SilentlyContinue |
                  Where-Object { $_.AccessRights -contains 'SendAs' -and $_.Trustee -notmatch $principalSkipPattern }
    } catch { }

    foreach ($p in $saPerm) {
        $src = $p.Trustee
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $RecipientCache
        if (-not $users -or $users.Count -eq 0) { continue }
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                RecipientType      = $type
                AccessType         = 'SendAs'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }

    # --- SendOnBehalf ---
    # Sørg for at vi har GrantSendOnBehalfTo – EXO trenger -Properties for å hente feltet
    $sobPrincipals = @()
    if ($mbx.PSObject.Properties.Name -contains 'GrantSendOnBehalfTo') {
        $sobPrincipals = @($mbx.GrantSendOnBehalfTo)
    } else {
        # fallback via klassisk cmdlet
        try {
            $mbxClassic = Get-Mailbox -Identity $mbx.Identity -ErrorAction Stop
            $sobPrincipals = @($mbxClassic.GrantSendOnBehalfTo)
        } catch { $sobPrincipals = @() }
    }

    foreach ($src in $sobPrincipals) {
        $users = Resolve-PrincipalToUsers -Principal $src -Cache $RecipientCache
        if (-not $users -or $users.Count -eq 0) { continue }
        foreach ($u in $users) {
            $rows += [pscustomobject]@{
                MailboxDisplayName = $name
                PrimarySmtp        = $smtp
                RecipientType      = $type
                AccessType         = 'SendOnBehalf'
                User               = $u
                SourcePrincipal    = $src
            }
        }
    }
}

# ---------- Eksport ----------

if ($OutputStyle -eq 'Normalized') {
    $export = $rows | Sort-Object MailboxDisplayName, AccessType, User -Unique
    $export | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Ferdig. Normalisert rapport: $OutputPath" -ForegroundColor Green
}
else {
    # Wide: én rad per postboks med semikolon-lister
    $wide = $rows | Group-Object MailboxDisplayName, PrimarySmtp, RecipientType | ForEach-Object {
        $g = $_.Group
        $mbxName = $g[0].MailboxDisplayName
        $mbxSmtp = $g[0].PrimarySmtp
        $mbxType = $g[0].RecipientType

        $fa = $g | Where-Object { $_.AccessType -eq 'FullAccess' }     | Select-Object -ExpandProperty User -Unique | Sort-Object
        $sa = $g | Where-Object { $_.AccessType -eq 'SendAs' }         | Select-Object -ExpandProperty User -Unique | Sort-Object
        $sb = $g | Where-Object { $_.AccessType -eq 'SendOnBehalf' }   | Select-Object -ExpandProperty User -Unique | Sort-Object

        [pscustomobject]@{
            MailboxDisplayName = $mbxName
            PrimarySmtp        = $mbxSmtp
            RecipientType      = $mbxType
            FullAccessUsers    = ($fa -join '; ')
            SendAsUsers        = ($sa -join '; ')
            SendOnBehalfUsers  = ($sb -join '; ')
        }
    } | Sort-Object MailboxDisplayName

    $wide | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "Ferdig. Oppsummeringsrapport: $OutputPath" -ForegroundColor Green
}

# Slutt
``