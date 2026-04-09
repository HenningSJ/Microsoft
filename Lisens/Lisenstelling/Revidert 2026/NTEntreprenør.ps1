<#
================================================================================
Navn:     NT Entreprenør – Lisensrapport (M2026)
Beskrivelse:
- Lisensrapport for NT Entreprenør
- Fordeling basert på e‑postdomene
================================================================================
#>

#region Konfigurasjon

$Config = @{
    TenantId        = "69104e7f-6c38-41b7-aedf-ba60ffdc6668"
    ClientId        = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint  = "C3AAA19174488E257748BF732523B3534841865D"

    CustomerName    = "NT Entreprenør"

    Companies = @(
        @{ Name = "NT Entreprenør";   Filter = "*@ntentreprenor.no" }
        @{ Name = "NT Byggservice";   Filter = "*@ntbyggservice.no" }
        @{ Name = "NT Eiendom";       Filter = "*@nteiendom.no" }
    )

    OutputDirectory = "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\NT Entreprenør"
    ExportCSV  = $true
    ExportText = $true
}

#endregion

#region Import felles funksjoner
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Start

Write-Host "`n=== Lisensrapport – $($Config.CustomerName) ===" -ForegroundColor Cyan

if (-not (Connect-M365GraphAPI `
    -TenantId $Config.TenantId `
    -ClientId $Config.ClientId `
    -CertThumbprint $Config.CertThumbprint))
{
    throw "Kunne ikke koble til Graph"
}

$skus = Get-AllTenantSKUs
if ($skus.Count -eq 0) { throw "Ingen SKUer funnet" }

$reportData = @()

foreach ($skuId in $skus.Keys) {
    $sku = $skus[$skuId]

    Write-Host "Behandler: $($sku.FriendlyName)" -ForegroundColor Gray

    $distribution = Get-LicenseUsersPerCompany `
        -SkuId $skuId `
        -Companies $Config.Companies

    if (-not $distribution) { continue }

    foreach ($company in $Config.Companies) {
        $reportData += [PSCustomObject]@{
            LicenseType       = $sku.FriendlyName
            SkuPartNumber     = $sku.SkuPartNumber
            CompanyName       = $company.Name
            LicenseCount      = $distribution[$company.Name]
            TotalLicenses     = $sku.TotalLicenses
            ConsumedLicenses  = $sku.ConsumedLicenses
            AvailableLicenses = $sku.AvailableLicenses
            ReportDate        = Get-Date
        }
    }
}

#endregion

#region Eksport

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$basePath = Join-Path $Config.OutputDirectory "NT-Entreprenor-$timestamp"

if ($Config.ExportCSV) {
    Export-ReportToCSV `
        -ReportData $reportData `
        -OutputPath "$basePath.csv"
}

if ($Config.ExportText) {
    Export-ReportToText `
        -ReportData $reportData `
        -OutputPath "$basePath.txt" `
        -CustomerName $Config.CustomerName
}

Write-Host "`n✓ Rapport fullført" -ForegroundColor Green

#endregion
