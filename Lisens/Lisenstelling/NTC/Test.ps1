<#
=============================================================================================
Name:           Office 365 / Microsoft 365 license reporting tool (refaktorert)
Description:    Skriver full lisensrapport inkl. totalsummer, utildelte, per-selskap og brukerlister.
Forfatter:      Henning + M365 Copilot (refaktor)
Dato:           Oppdatert: (Get-Date)
Notater:
 - Teller "utildelte" som PrepaidUnits.Enabled - ConsumedUnits (Microsoft Graph 'subscribedSkus')
 - Microsoft Teams Rooms Pro inkludert (riktig PartNumber). Panels krever Pro. Basic maks 25 rom.
   Kilder:
   - Teams Rooms lisensiering: https://learn.microsoft.com/en-us/microsoftteams/rooms/rooms-licensing
   - Teams Rooms priser/planer: https://www.microsoft.com/en-us/microsoft-teams/microsoft-teams-rooms/compare-rooms-plans
   - Graph subscribedSkus: https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku
=============================================================================================
#>

# --- Forutsigbar output/ytelse ---
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# --- Koble til Microsoft Graph ---
try {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
} catch {}

# NB: Lesestatus (Read) holder for rapportering
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All" | Out-Null

# --- Rapportfil ---
$FilePath = "C:\temp\O365Users-NTC.txt"
$null = New-Item -ItemType Directory -Path (Split-Path $FilePath) -Force -ErrorAction SilentlyContinue
Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue

$Today = Get-Date
"Oversikt over O365/M365 lisenene pr $Today" | Out-File -FilePath $FilePath -Encoding UTF8
"-----------------------------------------------------------"               | Out-File -Append $FilePath -Encoding UTF8
""                                                                           | Out-File -Append $FilePath -Encoding UTF8

# --- Hent alle SKUer én gang (ytelse/robusthet) ---
$allSkus = Get-MgSubscribedSku -All

function Get-SkuSummary {
    <#
      Returnerer: PartNumber, SkuId, Enabled, Consumed, Unassigned
      Unassigned = PrepaidUnits.Enabled - ConsumedUnits
      Kilde: Graph subscribedSkus https://learn.microsoft.com/en-us/graph/api/resources/subscribedsku
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
    " $DisplayName = Kunde har totalt $($SummaryObject.Enabled) lisenser"     | Out-File -Append $FilePath -Encoding UTF8
    " $DisplayName = Kunde har $($SummaryObject.Unassigned) utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
    ""                                                                           | Out-File -Append $FilePath -Encoding UTF8
}

# --- Definer PartNumbers (bruk tenantens PartNumber som fasit) ---
# Generelle Microsoft 365/Office/Exchange
$PN_BP             = "SPB"                        # Microsoft 365 Business Premium
$PN_BS             = "O365_BUSINESS_PREMIUM"      # Microsoft 365 Business Standard
$PN_BB             = "O365_BUSINESS_ESSENTIALS"   # Microsoft 365 Business Basic
$PN_EXO1           = "EXCHANGESTANDARD"           # Exchange Online Plan 1
$PN_EXO2           = "EXCHANGEENTERPRISE"         # Exchange Online Plan 2
$PN_EXOK           = "EXCHANGEDESKLESS"           # Exchange Online Kiosk
$PN_FLOW_PU        = "FLOW_PER_USER"              # Power Automate per user
$PN_PBI_PRO        = "POWER_BI_PRO"               # Power BI Pro
$PN_PBI_PPU        = "PBI_PREMIUM_PER_USER"       # Power BI Premium Per User
$PN_COPILOT        = "Microsoft_365_Copilot"      # Microsoft 365 Copilot (PartNumber kan variere; valider i tenant)
$PN_F1             = "Microsoft_365_F1_EEA_(no_Teams)"  # EEA uten Teams (som i eksisterende script/tenant)
$PN_SPSTORAGE      = "SHAREPOINTSTORAGE"          # Extra SharePoint storage (GB)
# Teams Rooms
$PN_TR_PRO         = "Microsoft_Teams_Rooms_Pro"  # Teams Rooms Pro (Panels krever Pro) – se kilder i header

# --- Hent summer for alle SKUer ---
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

# --- Topp: totalsummer per lisens (korrekt "utildelte") ---
Write-LicenseTotals "Microsoft 365 Business Premium"          $SUM_BP
Write-LicenseTotals "Microsoft 365 Business Standard"         $SUM_BS
Write-LicenseTotals "Microsoft 365 Business Basic"            $SUM_BB
Write-LicenseTotals "PowerBI Pro"                              $SUM_PBI_PRO
Write-LicenseTotals "PowerBI Premium (Per User)"               $SUM_PBI_PPU
Write-LicenseTotals "Exchange Online Plan 1"                   $SUM_EXO1
Write-LicenseTotals "Exchange Online Plan 2"                   $SUM_EXO2
Write-LicenseTotals "Exchange Online Kiosk"                    $SUM_EXOK
Write-LicenseTotals "Power Automate Per user Plan"             $SUM_FLOW_PU
Write-LicenseTotals "Microsoft 365 F1"                         $SUM_F1
Write-LicenseTotals "Microsoft 365 Copilot"                    $SUM_COPILOT

# SharePoint ekstra lagring – skriv som GB
" Office365 Extra File Storage (Utvidelse SharePoint-lagring) = Kunde har totalt $($SUM_SPSTORAGE.Enabled) GB med ekstra SharePoint-lagring" |
  Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding UTF8

# --- Teams Rooms Pro totalsum (egen seksjon) ---
Write-LicenseTotals "Microsoft Teams Rooms Pro" $SUM_TR_PRO

"-----------------------------------------------------------" | Out-File -Append $FilePath -Encoding UTF8
""                       | Out-File -Append $FilePath -Encoding UTF8


# --- Hent alle brukere én gang ---
$allUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,CompanyName"

function Get-LicenseUsers {
    param([Parameter(Mandatory)][string]$SkuId)
    if ([string]::IsNullOrWhiteSpace($SkuId)) { return @() }
    $allUsers | Where-Object { $_.AssignedLicenses -and ($_.AssignedLicenses.SkuId -contains $SkuId) }
}

function Count-ByOrganization {
    param([Parameter(Mandatory)][array]$Users)

    # Filtreringsregler (samme som i tidligere script):
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

# --- Per-selskap seksjoner (som i opprinnelig script), men med riktig SkuId og telling ---
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

# --- Brukerlister per lisens (som i opprinnelig rapport), korrekt formatert ---
Write-UserList -Title "MICROSOFT 365 BUSINESS STANDARD" -Users (Get-LicenseUsers $SUM_BS.SkuId)
Write-UserList -Title "MICROSOFT 365 BUSINESS BASIC"   -Users (Get-LicenseUsers $SUM_BB.SkuId)
Write-UserList -Title "MICROSOFT 365 BUSINESS PREMIUM" -Users (Get-LicenseUsers $SUM_BP.SkuId)
Write-UserList -Title "EXCHANGE ONLINE PLAN 1"          -Users (Get-LicenseUsers $SUM_EXO1.SkuId)
Write-UserList -Title "EXCHANGE ONLINE PLAN 2"          -Users (Get-LicenseUsers $SUM_EXO2.SkuId)
Write-UserList -Title "EXCHANGE ONLINE KIOSK"           -Users (Get-LicenseUsers $SUM_EXOK.SkuId)
Write-UserList -Title "POWER BI PRO"                    -Users (Get-LicenseUsers $SUM_PBI_PRO.SkuId)
Write-UserList -Title "POWER BI PREMIUM"                -Users (Get-LicenseUsers $SUM_PBI_PPU.SkuId)
Write-UserList -Title "POWER AUTOMATE PER USER"         -Users (Get-LicenseUsers $SUM_FLOW_PU.SkuId)
Write-UserList -Title "MICROSOFT 365 COPILOT"           -Users (Get-LicenseUsers $SUM_COPILOT.SkuId)
Write-UserList -Title "MICROSOFT 365 F1"                -Users (Get-LicenseUsers $SUM_F1.SkuId)
Write-UserList -Title "MICROSOFT TEAMS ROOMS PRO"       -Users (Get-LicenseUsers $SUM_TR_PRO.SkuId)

# --- Slutt ---
"Rapport generert: $Today" | Out-File -Append $FilePath -Encoding UTF8
