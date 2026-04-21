<#
.SYNOPSIS
    Lisensrapport for IBID tenant
.DESCRIPTION
    Henter og rapporterer Microsoft 365 lisenser fordelt på barnehager
    basert på e-postdomener
.NOTES
    Kunde: IBID (flere barnehager)
    TenantId: 256c6ac2-bdec-4852-894d-4995d602734f
#>

#region Konfigurasjon
$Config = @{
    # Tenant-informasjon
    TenantId = "256c6ac2-bdec-4852-894d-4995d602734f"
    ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"
    
    # Kundenavn
    CustomerName = "IBID"
    
    # Filtertype
    FilterType = "Domain"
    
    # Barnehager og deres domener
    Companies = @(
        @{ Name = "IBID"; Filter = "*@ibid-sa.no" }
        @{ Name = "IBID Administrasjon"; Filter = "*@ibidsa.onmicrosoft.com" }
        @{ Name = "Liøya Barnehage"; Filter = "*@lioya.no" }
        @{ Name = "Barnehagen Hundre"; Filter = "*@barnehagenhundre.no" }
        @{ Name = "Domkirkens Barnehage"; Filter = "*@domkirkens.no" }
        @{ Name = "Ekrehagen Barnehage"; Filter = "*@ekrehagen.com" }
        @{ Name = "Kråkeslottet Barnehage"; Filter = "*@kraakeslottet.no" }
        @{ Name = "Kveldrovegen Barnehage"; Filter = "*@kveldrovegen.no" }
        @{ Name = "Norrønna Barnehage"; Filter = "*@norrona-barnehage.no" }
        @{ Name = "Polarhagen Barnehage"; Filter = "*@polarhagen-barnehage.no" }
        @{ Name = "Soldagen Barnehage"; Filter = "*@Soldagenbhg.no" }
        @{ Name = "Tusseladden Barnehage"; Filter = "*@tusseladden.com" }
        @{ Name = "Åsland Barnehage"; Filter = "*@aabhg.no" }
        @{ Name = "Skogstua Barnehage"; Filter = "*@skogstuabarnehage.no" }
        @{ Name = "Karveslettlia Barnehage"; Filter = "*@karveslettlia.no" }
        @{ Name = "Hamna Friluftsbarnehage"; Filter = "*@hamnafriluftsbarnehage.no" }
        @{ Name = "Trollskogen Barnehage"; Filter = "*@trollskogenbarn.no" }
        @{ Name = "Kanutten Barnehage"; Filter = "*@kanuttenbh.no" }
        @{ Name = "Ameliahaugen Barnehage"; Filter = "*@ameliahaugen.no" }
        @{ Name = "Bjerkaker Barnehage"; Filter = "*@bjerkakerbarnehage.no" }
        @{ Name = "Kulturbarnehagen"; Filter = "*@kulturbarnehagen.tromso.no" }
        @{ Name = "Bamsestua Barnehage"; Filter = "*@bamsestua.no" }
    )
    
    # Rapportinnstillinger
    OutputDirectory = "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\IBID"
    ExportCSV = $true
    ExportText = $true
}
#endregion

#region Import av felles funksjoner
# [Inkluder eller importer felles modul her]
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Hovedskript

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Microsoft 365 Lisensrapport - $($Config.CustomerName)" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Koble til Microsoft Graph
$connected = Connect-M365GraphAPI -TenantId $Config.TenantId `
                                   -ClientId $Config.ClientId `
                                   -CertThumbprint $Config.CertThumbprint

if (-not $connected) {
    Write-Error "Kunne ikke koble til Microsoft Graph. Avbryter."
    exit 1
}

# Hent alle SKUer fra tenanten
$allSKUs = Get-AllTenantSKUs

if ($allSKUs.Count -eq 0) {
    Write-Error "Ingen SKUer funnet i tenanten. Avbryter."
    exit 1
}

Write-Host "`nProsesserer lisenser per barnehage..." -ForegroundColor Cyan
Write-Host "Antall barnehager: $($Config.Companies.Count)" -ForegroundColor Gray

# Samle rapportdata
$reportData = @()

foreach ($skuId in $allSKUs.Keys) {
    $sku = $allSKUs[$skuId]
    $friendlyName = Get-FriendlyLicenseName -SkuPartNumber $sku.SkuPartNumber
    
    Write-Host "  Prosesserer: $friendlyName" -ForegroundColor Gray
    
    # Hent lisensfordeling per barnehage
    $companyDistribution = Get-LicenseUsersPerCompany -SkuId $skuId `
                                                       -Companies $Config.Companies `
                                                       -FilterType $Config.FilterType
    
    # Lag datarader for hver barnehage
    foreach ($company in $Config.Companies) {
        $reportData += [PSCustomObject]@{
            LicenseType = $friendlyName
            SkuPartNumber = $sku.SkuPartNumber
            SkuId = $sku.SkuId
            CompanyName = $company.Name
            LicenseCount = $companyDistribution[$company.Name]
            TotalLicenses = $sku.TotalLicenses
            ConsumedLicenses = $sku.ConsumedLicenses
            AvailableLicenses = $sku.AvailableLicenses
            ReportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

Write-Host "`n✓ Datainnsamling fullført" -ForegroundColor Green

# Eksporter rapporter
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$baseFileName = "O365Users-$($Config.CustomerName)-$timestamp"

if ($Config.ExportCSV) {
    $csvPath = Join-Path $Config.OutputDirectory "$baseFileName.csv"
    Export-ReportToCSV -ReportData $reportData -OutputPath $csvPath
}

if ($Config.ExportText) {
    $textPath = Join-Path $Config.OutputDirectory "$baseFileName.txt"
    Export-ReportToText -ReportData $reportData `
                               -OutputPath $textPath `
                               -CustomerName $Config.CustomerName
}


# Vis sammendrag
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Sammendrag" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Antall lisenstyper prosessert: $($allSKUs.Count)" -ForegroundColor White
Write-Host "Antall barnehager: $($Config.Companies.Count)" -ForegroundColor White
Write-Host "Totalt datarader: $($reportData.Count)" -ForegroundColor White
Write-Host "`n✓ Skript fullført!" -ForegroundColor Green

#endregion