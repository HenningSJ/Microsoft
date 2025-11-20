<#
=============================================================================================
Name:           M365 License Reporting Tool (refaktorert)
Description:    Full lisensrapport (totalsummer, utildelte, per-selskap og brukerlister).
                Inkluderer Microsoft Teams Rooms Pro, avvikssjekk og liste over ikke-klassifiserte.
Forfatter:      Henning + M365 Copilot (refaktor)
Dato:           (Get-Date)

Viktige prinsipper:
- "Utildelte" = PrepaidUnits.Enabled - ConsumedUnits (fra Microsoft Graph 'subscribedSkus').
  Se: https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku
- Teams Rooms: Basic vs Pro (Panels krever Pro, Basic maks 25 rom).
  Se: https://learn.microsoft.com/en-us/microsoftteams/rooms/rooms-licensing
- Planer/priser for Teams Rooms: https://www.microsoft.com/en-us/microsoft-teams/microsoft-teams-rooms/compare-rooms-plans
=============================================================================================
#>

# ---------------------------------------------
# 0) Forutsigbar output/feil
# ---------------------------------------------
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# ---------------------------------------------
# 1) Graph-tilkobling (read-only)
# ---------------------------------------------
try { Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null } catch {}
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All" | Out-Null

# ---------------------------------------------
# 2) Rapportfil
# ---------------------------------------------
$FilePath = "C:\temp\O365Users-NTC.txt"
$null = New-Item -ItemType Directory -Path (Split-Path $FilePath) -Force -ErrorAction SilentlyContinue
Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue

$Today = Get-Date
"Oversikt over O365/M365 lisenene pr $Today" | Out-File -FilePath $FilePath -Encoding UTF8
"-----------------------------------------------------------"               | Out-File -Append $FilePath -Encoding UTF8
""                                                                           | Out-File -Append $FilePath -Encoding UTF8

# ---------------------------------------------
# 3) Hent data (én gang)
# ---------------------------------------------
$allSkus  = Get-MgSubscribedSku -All
$allUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,CompanyName"

# ---------------------------------------------
# 4) Hjelpefunksjoner
# ---------------------------------------------
function Get-SkuSummary {
    <#
      Input:  SkuPartNumber
      Output: PartNumber, SkuId, Enabled, Consumed, Unassigned
      Unassigned = PrepaidUnits.Enabled - ConsumedUnits (ikke bruk ActiveUnits i formelen)
      Kilde: https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku
    #>
    param([Parameter(Mandatory)][string]$SkuPartNumber)

    $sku = $allSkus | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber }
    if (-not $sku) {
        return [pscustomobject]@{
            PartNumber = $SkuPartNumber
            SkuId      = $null
            Enabled    = 0
            Consumed   = 0
            Unassigned = 0
        }
    }

    $enabled    = [int]$sku.PrepaidUnits.Enabled
    $consumed   = [int]$sku.ConsumedUnits
    $unassigned = [math]::Max(0, $enabled - $consumed)

    [pscustomobject]@{
        PartNumber = $SkuPartNumber
        SkuId      = $sku.SkuId
        Enabled    = $enabled
        Consumed   = $consumed
        Unassigned = $unassigned
    }
}

function Write-LicenseTotals {
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][pscustomobject]$SummaryObject
    )
    # Skriver totalsum og utildelte for en gitt lisens
    " $DisplayName = Kunde har totalt $($SummaryObject.Enabled) lisenser"       | Out-File -Append $FilePath -Encoding UTF8
    " $DisplayName = Kunde har $($SummaryObject.Unassigned) utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
    ""                                                                           | Out-File -Append $FilePath -Encoding UTF8
}

function Get-LicenseUsers {
    param([Parameter(Mandatory)][string]$SkuId)
    if ([string]::IsNullOrWhiteSpace($SkuId)) { return @() }
    $allUsers | Where-Object { $_.AssignedLicenses -and ($_.AssignedLicenses.SkuId -contains $SkuId) }
}

function Count-ByOrganization {
    param([Parameter(Mandatory)][array]$Users)
    # Filterregler (tilpass ved behov)
    $countNTC        = ($Users | Where-Object { $_.Department  -like "NTC" }).Count
    $countRomsdalen  = ($Users | Where-Object { $_.Department  -like "Romsdalen" }).Count
    $countFjell      = ($Users | Where-Object { $_.Department  -like "Fjellheisen AS" }).Count
    $countSnow       = ($Users | Where-Object { ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes") }).Count
    $countArctic     = ($Users | Where-Object { $_.Department  -like "Arctic Train AS" }).Count
    $countSommaroy   = ($Users | Where-Object { $_.Department  -like "Sommarøy Arctic Hotel AS" }).Count

    [pscustomobject]@{
        NTC        = $countNTC
        Romsdalen  = $countRomsdalen
        Fjellheisen= $countFjell
        SnowHotel  = $countSnow
        ArcticTrain= $countArctic
        Sommaroy   = $countSommaroy
    }
}

function Write-PerCompanySection {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$SkuId
    )
    $users = Get-LicenseUsers -SkuId $SkuId
    Write-Output $Title | Out-File -Append $FilePath -Encoding UTF8

    $c = Count-ByOrganization -Users $users
    "NTC: $($c.NTC)"                                   | Out-File -Append $FilePath -Encoding UTF8
    "Romsdalen: $($c.Romsdalen)"                       | Out-File -Append $FilePath -Encoding UTF8
    "Fjellheisen: $($c.Fjellheisen)"                   | Out-File -Append $FilePath -Encoding UTF8
    "Snow Hotel Kirkenes: $($c.SnowHotel)"             | Out-File -Append $FilePath -Encoding UTF8
    "Arctic Train: $($c.ArcticTrain)"                  | Out-File -Append $FilePath -Encoding UTF8
    "Sommarøy Arctic Hotel AS: $($c.Sommaroy)"         | Out-File -Append $FilePath -Encoding UTF8
    ""                                                 | Out-File -Append $FilePath -Encoding UTF8
}

function Write-UserList {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][array]$Users
    )
    "OVERSIKT OVER BRUKERE MED $Title LISENS" | Out-File -Append $FilePath -Encoding UTF8
    "***************************************************************" | Out-File -Append $FilePath -Encoding UTF8

    if (-not $Users -or $Users.Count -eq 0) {
        "(Ingen)" | Out-File -Append $FilePath -Encoding UTF8
    } else {
        $Users | Select-Object DisplayName, UserPrincipalName |
            Sort-Object DisplayName |
            Format-Table -AutoSize | Out-String |
            Out-File -Append $FilePath -Encoding UTF8
    }
    "" | Out-File -Append $FilePath -Encoding UTF8
    "-----------------------------------------------------------" | Out-File -Append $FilePath -Encoding UTF8
}

function Write-DiscrepancyCheck {
    <#
      Skriver en kontrollseksjon som sammenligner:
      - Enabled (kjøpt)
      - Consumed (tildelt ifølge SKU)
      - Brukerliste (antall vi fanget i Get-LicenseUsers)
      Rapporterer evt. avvik.
    #>
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][pscustomobject]$SummaryObject,
        [Parameter(Mandatory)][array]$Users
    )
    $enabled    = $SummaryObject.Enabled
    $consumed   = $SummaryObject.Consumed
    $unassigned = $SummaryObject.Unassigned
    $countUsers = ($Users | Measure-Object).Count

    "[$Title] Kontroll:"                             | Out-File -Append $FilePath -Encoding UTF8
    "Kjøpt (Enabled):          $enabled"             | Out-File -Append $FilePath -Encoding UTF8
    "Tildelt (Consumed):       $consumed"            | Out-File -Append $FilePath -Encoding UTF8
    "Tildelt (brukerliste):    $countUsers"          | Out-File -Append $FilePath -Encoding UTF8
    "Utildelte (beregnet):     $unassigned"          | Out-File -Append $FilePath -Encoding UTF8

    $delta = $consumed - $countUsers
    if ($delta -ne 0) {
        "Avvik: Consumed - brukerliste = $delta (sjekk ressurskontoer/filtre/Department/CompanyName)" |
          Out-File -Append $FilePath -Encoding UTF8
    } else {
        "Avvik: Ingen" | Out-File -Append $FilePath -Encoding UTF8
    }
    "" | Out-File -Append $FilePath -Encoding UTF8
}

function Write-NonClassifiedList {
    <#
      Viser brukere med lisensen som ikke matcher noen av selskap/avdeling-reglene.
      Hjelper å finne "forsvunne" lisenser som ikke vises i per-selskap-tellingene.
    #>
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][array]$Users
    )
    $non = $Users | Where-Object {
        ($_.Department -notlike "NTC") -and
        ($_.Department -notlike "Romsdalen") -and
        ($_.Department -notlike "Fjellheisen AS") -and
        ($_.Department -notlike "Arctic Train AS") -and
        ($_.Department -notlike "Sommarøy Arctic Hotel AS") -and
        ($_.CompanyName -notlike "Snowhotel Kirkenes") -and
        ($_.CompanyName -notlike "Snow Resort Kirkenes")
    }

    "[$Title] Brukere uten klassifisering (Department/CompanyName):" | Out-File -Append $FilePath -Encoding UTF8
    if ($non.Count -eq 0) {
        "(Ingen)" | Out-File -Append $FilePath -Encoding UTF8
    } else {
        $non | Select-Object DisplayName, UserPrincipalName, Department, CompanyName |
            Sort-Object DisplayName |
            Format-Table -AutoSize | Out-String |
            Out-File -Append $FilePath -Encoding UTF8
    }
    "" | Out-File -Append $FilePath -Encoding UTF8
}

# ---------------------------------------------
# 5) PartNumbers (valider i din tenant ved behov)
# ---------------------------------------------
$PN_BP        = "SPB"                        # M365 Business Premium
$PN_BS        = "O365_BUSINESS_PREMIUM"      # M365 Business Standard
$PN_BB        = "O365_BUSINESS_ESSENTIALS"   # M365 Business Basic
$PN_EXO1      = "EXCHANGESTANDARD"           # Exchange Online Plan 1
$PN_EXO2      = "EXCHANGEENTERPRISE"         # Exchange Online Plan 2
$PN_EXOK      = "EXCHANGEDESKLESS"           # Exchange Online Kiosk
$PN_FLOW_PU   = "FLOW_PER_USER"              # Power Automate per user
$PN_PBI_PRO   = "POWER_BI_PRO"               # Power BI Pro
$PN_PBI_PPU   = "PBI_PREMIUM_PER_USER"       # Power BI Premium Per User (PPU)
$PN_COPILOT   = "Microsoft_365_Copilot"      # Microsoft 365 Copilot (valider i tenant)
$PN_F1        = "Microsoft_365_F1_EEA_(no_Teams)"  # EEA (uten Teams) - valider i tenant
$PN_SPSTORAGE = "SHAREPOINTSTORAGE"          # Extra SharePoint storage (GB)
$PN_TR_PRO    = "Microsoft_Teams_Rooms_Pro"  # Teams Rooms Pro

# ---------------------------------------------
# 6) Summer per SKU
# ---------------------------------------------
$SUM_BP        = Get-SkuSummary $PN_BP
$SUM_BS        = Get-SkuSummary $PN_BS
$SUM_BB        = Get-SkuSummary $PN_BB
$SUM_EXO1      = Get-SkuSummary $PN_EXO1
$SUM_EXO2      = Get-SkuSummary $PN_EXO2
$SUM_EXOK      = Get-SkuSummary $PN_EXOK
$SUM_FLOW_PU   = Get-SkuSummary $PN_FLOW_PU
$SUM_PBI_PRO   = Get-SkuSummary $PN_PBI_PRO
$SUM_PBI_PPU   = Get-SkuSummary $PN_PBI_PPU
$SUM_COPILOT   = Get-SkuSummary $PN_COPILOT
$SUM_F1        = Get-SkuSummary $PN_F1
$SUM_SPSTORAGE = Get-SkuSummary $PN_SPSTORAGE
$SUM_TR_PRO    = Get-SkuSummary $PN_TR_PRO

# ---------------------------------------------
# 7) Topp: totalsummer per lisens
# ---------------------------------------------
Write-LicenseTotals "Microsoft 365 Business Premium"         $SUM_BP
Write-LicenseTotals "Microsoft 365 Business Standard"        $SUM_BS
Write-LicenseTotals "Microsoft 365 Business Basic"           $SUM_BB
Write-LicenseTotals "PowerBI Pro"                            $SUM_PBI_PRO
Write-LicenseTotals "PowerBI Premium (Per User)"             $SUM_PBI_PPU
Write-LicenseTotals "Exchange Online Plan 1"                 $SUM_EXO1
Write-LicenseTotals "Exchange Online Plan 2"                 $SUM_EXO2
Write-LicenseTotals "Exchange Online Kiosk"                  $SUM_EXOK
Write-LicenseTotals "Power Automate Per user Plan"           $SUM_FLOW_PU
Write-LicenseTotals "Microsoft 365 F1"                       $SUM_F1
Write-LicenseTotals "Microsoft 365 Copilot"                  $SUM_COPILOT

# SharePoint Extra Storage (GB, ikke "lisenser")
" Office365 Extra File Storage (Utvidelse SharePoint-lagring) = Kunde har totalt $($SUM_SPSTORAGE.Enabled) GB med ekstra SharePoint-lagring" |
  Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding UTF8

# Teams Rooms Pro totalsum (linjen skal komme etter TR Pro)
Write-LicenseTotals "Microsoft Teams Rooms Pro" $SUM_TR_PRO
"-----------------------------------------------------------" | Out-File -Append $FilePath -Encoding UTF8
""                       | Out-File -Append $FilePath -Encoding UTF8

# ---------------------------------------------
# 8) Per-selskap seksjoner
# ---------------------------------------------
Write-PerCompanySection -Title "Microsoft 365 Business Premium" -SkuId $SUM_BP.SkuId
Write-PerCompanySection -Title "Microsoft 365 Business Standard" -SkuId $SUM_BS.SkuId
Write-PerCompanySection -Title "Microsoft 365 Business Basic" -SkuId $SUM_BB.SkuId
Write-PerCompanySection -Title "Microsoft 365 Copilot" -SkuId $SUM_COPILOT.SkuId
Write-PerCompanySection -Title "Exchange Online Plan 1" -SkuId $SUM_EXO1.SkuId
Write-PerCompanySection -Title "Exchange Online Plan 2" -SkuId $SUM_EXO2.SkuId
Write-PerCompanySection -Title "Exchange Online Kiosk" -SkuId $SUM_EXOK.SkuId
Write-PerCompanySection -Title "PowerBI Pro" -SkuId $SUM_PBI_PRO.SkuId
Write-PerCompanySection -Title "PowerBI Premium" -SkuId $SUM_PBI_PPU.SkuId
Write-PerCompanySection -Title "Power Automate Users" -SkuId $SUM_FLOW_PU.SkuId
Write-PerCompanySection -Title "Microsoft 365 F1" -SkuId $SUM_F1.SkuId
Write-PerCompanySection -Title "Microsoft Teams Rooms Pro" -SkuId $SUM_TR_PRO.SkuId

# ---------------------------------------------
# 9) Brukerlister per lisens
# ---------------------------------------------
# Merk: For Business Basic tar vi vare på lista i en variabel for å kjøre avvikssjekk og ikke-klassifisert-utskrift
$Users_BS  = Get-LicenseUsers $SUM_BS.SkuId
$Users_BB  = Get-LicenseUsers $SUM_BB.SkuId
$Users_BP  = Get-LicenseUsers $SUM_BP.SkuId
$Users_EX1 = Get-LicenseUsers $SUM_EXO1.SkuId
$Users_EX2 = Get-LicenseUsers $SUM_EXO2.SkuId
$Users_EXK = Get-LicenseUsers $SUM_EXOK.SkuId
$Users_PBI = Get-LicenseUsers $SUM_PBI_PRO.SkuId
$Users_PPU = Get-LicenseUsers $SUM_PBI_PPU.SkuId
$Users_FLO = Get-LicenseUsers $SUM_FLOW_PU.SkuId
$Users_COP = Get-LicenseUsers $SUM_COPILOT.SkuId
$Users_F1  = Get-LicenseUsers $SUM_F1.SkuId
$Users_TRP = Get-LicenseUsers $SUM_TR_PRO.SkuId

Write-UserList -Title "MICROSOFT 365 BUSINESS STANDARD" -Users $Users_BS
Write-UserList -Title "MICROSOFT 365 BUSINESS BASIC"   -Users $Users_BB
Write-UserList -Title "MICROSOFT 365 BUSINESS PREMIUM" -Users $Users_BP
Write-UserList -Title "EXCHANGE ONLINE PLAN 1"          -Users $Users_EX1
Write-UserList -Title "EXCHANGE ONLINE PLAN 2"          -Users $Users_EX2
Write-UserList -Title "EXCHANGE ONLINE KIOSK"           -Users $Users_EXK
Write-UserList -Title "POWER BI PRO"                    -Users $Users_PBI
Write-UserList -Title "POWER BI PREMIUM"                -Users $Users_PPU
Write-UserList -Title "POWER AUTOMATE PER USER"         -Users $Users_FLO
Write-UserList -Title "MICROSOFT 365 COPILOT"           -Users $Users_COP
Write-UserList -Title "MICROSOFT 365 F1"                -Users $Users_F1
Write-UserList -Title "MICROSOFT TEAMS ROOMS PRO"       -Users $Users_TRP

# ---------------------------------------------
# 10) Avvikssjekk + ikke-klassifiserte (Business Basic)
# ---------------------------------------------
Write-DiscrepancyCheck -Title "Microsoft 365 Business Basic" -SummaryObject $SUM_BB -Users $Users_BB
Write-NonClassifiedList -Title "Microsoft 365 Business Basic" -Users $Users_BB

# ---------------------------------------------
# 11) Slutt
# ---------------------------------------------
"Rapport generert: $Today" | Out-File -Append $FilePath -Encoding UTF8