<#
================================================================================
Name:           NTC.ps1
Description:    Lisensrapport for NTC basert på felles funksjoner
Kunde:          The Norwegian Travel Company
Type:           Audit / Full rapport
================================================================================
#>

#region Import felles funksjoner
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Konfigurasjon

$Config = @{
    TenantId        = "8e5367a7-2ca1-49d1-978c-8c5c56aa874d"
    ClientId        = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint  = "C3AAA19174488E257748BF732523B3534841865D"

    CustomerName    = "NTC"

    OutputDirectory = "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\NTC"
    TempDirectory   = "C:\Temp\Lisenser-NTC"
    BaseFileName    = "Lisenser-NTC"

    ExportCSV       = $true
    ExportText      = $true
    IncludeUserLists = $true

    # ------------------------------------------------------------
    # Organisasjons‑regler (ALL logikk ligger her)
    # ------------------------------------------------------------
    Organizations = @(
        @{ Name = "NTC";                    Match = { $_.Department  -eq "NTC" } }
        @{ Name = "Romsdalen";              Match = { $_.Department  -eq "Romsdalen" } }
        @{ Name = "Fjellheisen";            Match = { $_.Department  -eq "Fjellheisen AS" } }
        @{ Name = "Snow Hotel Kirkenes";    Match = { $_.CompanyName -in @("Snowhotel Kirkenes", "Snow Resort Kirkenes") } }
        @{ Name = "Arctic Train";           Match = { $_.Department  -eq "Arctic Train AS" } }
        @{ Name = "Sommarøy Arctic Hotel";  Match = { $_.Department  -eq "Sommarøy Arctic Hotel AS" } }
    )

    # ------------------------------------------------------------
    # Lisenser som skal rapporteres
    # PartNumbers = kandidater, første som finnes brukes
    # ------------------------------------------------------------
    Licenses = @(
        @{ DisplayName = "Microsoft 365 Business Premium";       PartNumbers = @("SPB") }
        @{ DisplayName = "Microsoft 365 Business Standard";      PartNumbers = @("O365_BUSINESS_PREMIUM") }
        @{ DisplayName = "Microsoft 365 Business Basic";         PartNumbers = @("O365_BUSINESS_ESSENTIALS") }
        @{ DisplayName = "Power BI Pro";                          PartNumbers = @("POWER_BI_PRO") }
        @{ DisplayName = "Power BI Premium (Per User)";           PartNumbers = @("PBI_PREMIUM_PER_USER","POWER_BI_PREMIUM_PER_USER") }
        @{ DisplayName = "Exchange Online Plan 1";               PartNumbers = @("EXCHANGESTANDARD") }
        @{ DisplayName = "Exchange Online Plan 2";               PartNumbers = @("EXCHANGEENTERPRISE") }
        @{ DisplayName = "Exchange Online Kiosk";                PartNumbers = @("EXCHANGEDESKLESS") }
        @{ DisplayName = "Power Automate Per user";              PartNumbers = @("FLOW_PER_USER","FLOW_PER_USER_P2") }
        @{ DisplayName = "Microsoft 365 Copilot";                PartNumbers = @("Microsoft_365_Copilot") }
        @{ DisplayName = "Microsoft 365 F1";                      PartNumbers = @("M365_F1","SPE_F1","Microsoft_365_F1") }
        @{ DisplayName = "SharePoint Extra Storage (GB)";        PartNumbers = @("SHAREPOINTSTORAGE") }
        @{ DisplayName = "Microsoft Teams Rooms Pro";            PartNumbers = @("Microsoft_Teams_Rooms_Pro","MTR_PRO") }
    )
}

#endregion

#region Start

Write-Host "`n=== Starter lisensrapport – $($Config.CustomerName) ===" -ForegroundColor Cyan

if (-not (Connect-M365GraphAPI `
    -TenantId $Config.TenantId `
    -ClientId $Config.ClientId `
    -CertThumbprint $Config.CertThumbprint)) {
    throw "Klarte ikke å koble til Microsoft Graph"
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"

#Temp-mappe for å unngå OneDrive krøll
New-Item -ItemType Directory -Path $config.TempDirectory -Force | Out-Null

$txtPath = Join-Path $Config.OutputDirectory "$($Config.BaseFileName)-$timestamp.txt"
$csvPath = Join-Path $Config.OutputDirectory "$($Config.BaseFileName)-$timestamp.csv"
New-Item -ItemType Directory -Path $Config.OutputDirectory -Force

# Tøm filer
Remove-Item $txtPath,$csvPath -Force -ErrorAction SilentlyContinue

$Today = Get-Date
"Oversikt over O365/M365 lisenser pr $Today" | Out-File $txtPath -Encoding UTF8
"-----------------------------------------------------------" | Out-File -Append $txtPath -Encoding UTF8
"" | Out-File -Append $txtPath -Encoding UTF8

# Hent data én gang
$AllSkus  = Get-AllTenantSKUs
$AllUsers = Get-AllUsers

$csvRows = @()

foreach ($lic in $Config.Licenses) {

    $sum = Get-SkuSummary `
        -DisplayName $lic.DisplayName `
        -PartNumbers $lic.PartNumbers `
        -AllSkus $AllSkus

    # Totalsum
    Write-LicenseTotals -Summary $sum -OutputPath $txtPath

    # Brukere med lisensen
    if ([string]::IsNullOrWhiteSpace($sum.SkuId)) {
        # Lisensen finnes ikke i tenant (PartNumbers traff ikke) → ingen brukere
        $users = @()
    } else {
        $users = Get-LicenseUsers -Users $AllUsers -SkuId $sum.SkuId
    }

    # Per organisasjon
    $counts = Count-ByOrganization `
        -Users $users `
        -Organizations $Config.Organizations

    Write-PerCompanySection `
        -Title $sum.DisplayName `
        -Counts $counts `
        -OutputPath $txtPath

    # CSV
    if ($Config.ExportCSV) {
        foreach ($k in $counts.Keys) {
            $csvRows += [PSCustomObject]@{
                ReportDate  = $Today
                License     = $sum.DisplayName
                PartNumber = $sum.PartNumber
                Organization= $k
                Count       = $counts[$k]
                Enabled     = $sum.Enabled
                Consumed    = $sum.Consumed
                Unassigned  = $sum.Unassigned
            }
        }
    }

    if ($Config.IncludeUserLists -and $sum.PartNumber -ne "SHAREPOINTSTORAGE") {
        Write-UserList -Title $sum.DisplayName -Users $users -OutputPath $txtPath
        Write-DiscrepancyCheck -Title $sum.DisplayName -Summary $sum -Users $users -OutputPath $txtPath
        Write-NonClassifiedList -Title $sum.DisplayName -Users $users -Organizations $Config.Organizations -OutputPath $txtPath
        "" | Out-File -Append $txtPath -Encoding UTF8
    }
}

if ($Config.ExportCSV -and $csvRows.Count -gt 0) {
    $csvRows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force
}

Write-Host "✓ Rapport ferdig:" -ForegroundColor Green
Write-Host "  TXT: $txtPath"
if ($Config.ExportCSV) { Write-Host "  CSV: $csvPath" }


New-Item -ItemType Directory -Path $Config.OutputDirectory -Force | Out-Null

Move-Item $txtPath $Config.OutputDirectory -Force
if (Test-Path $csvPath) {
    Move-Item $csvPath $Config.OutputDirectory -Force
}


#endregion
