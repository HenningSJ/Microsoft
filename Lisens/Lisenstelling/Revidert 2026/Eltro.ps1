<#
.SYNOPSIS
    Microsoft 365 Lisensrapport for Eltro
    
.DESCRIPTION
    Henter og rapporterer lisenser fordelt på selskaper basert på e-postdomener.
    Genererer både CSV og TXT-rapport for månedlig kostnadsfordeling.
    
.NOTES
    Kunde: Eltro
    TenantId: 185b631d-f345-4e08-833d-70d929ead841
    Separeringsmetode: E-postdomene (@eltro.no vs @eltrovvs.no)
    
    Autentisering: App-basert med sertifikat (kan kjøres automatisk)
    
    Versjon: 2.0
    Sist oppdatert: 2026-04-01
#>

#region Konfigurasjon for Eltro


$Config = @{
    # Tenant autentisering
    TenantId = "185b631d-f345-4e08-833d-70d929ead841"
    ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"
    
    # Kundeinfo
    CustomerName = "Eltro"
    
    # Selskaper og deres domener
    Companies = @(
        @{ 
            Name = "Eltro"
            DomainFilter = "*@eltro.no"
        }
        @{ 
            Name = "Eltro VVS"
            DomainFilter = "*@eltrovvs.no"
        }
    )
    
    # Rapportinnstillinger
    OutputDirectory = "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\Eltro"
    GenerateCSV = $true
    GenerateTXT = $true
}

#endregion

#region Inkluder felles funksjoner
# [Kopier inn hele funksjonsbiblioteket fra over her]
# Alternativt: . ".\M365-Functions.ps1" hvis du lagrer som egen fil
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Hovedskript for Eltro

Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MICROSOFT 365 LISENSRAPPORT" -ForegroundColor Cyan
Write-Host "Kunde: $($Config.CustomerName)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Koble til Microsoft Graph
$connected = Connect-M365GraphAPI -TenantId $Config.TenantId `
                                   -ClientId $Config.ClientId `
                                   -CertThumbprint $Config.CertThumbprint

if (-not $connected) {
    Write-Error "Kunne ikke koble til Microsoft Graph. Avbryter skript."
    exit 1
}

# Hent alle tilgjengelige SKUer dynamisk fra tenanten
$allSKUs = Get-AllTenantSKUs

if ($allSKUs.Count -eq 0) {
    Write-Error "Ingen SKUer funnet i tenanten. Sjekk tilkobling og rettigheter."
    exit 1
}

Write-Host "`nProsesserer lisenser for $($Config.Companies.Count) selskaper..." -ForegroundColor Cyan
Write-Host "Antall lisenstyper funnet: $($allSKUs.Count)" -ForegroundColor Gray
Write-Host ""

# Samle rapportdata
$reportData = @()
$processedCount = 0

foreach ($skuId in $allSKUs.Keys) {
    $sku = $allSKUs[$skuId]
    $processedCount++
    
    Write-Host "[$processedCount/$($allSKUs.Count)] Prosesserer: $($sku.FriendlyName)" -ForegroundColor Gray
    
    # Hent lisensfordeling per selskap
    $companyDistribution = Get-LicenseCountByDomain -SkuId $skuId `
                                                     -Companies $Config.Companies
    
    # Legg til datarad for hvert selskap
    foreach ($company in $Config.Companies) {
        $reportData += [PSCustomObject]@{
            LicenseType = $sku.FriendlyName
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

Write-Host "`n✓ Datainnsamling fullført ($($reportData.Count) datarader)" -ForegroundColor Green

# Generer rapporter
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$baseFileName = "O365-Lisensrapport-Eltro-$timestamp"

Write-Host "`nGenererer rapporter..." -ForegroundColor Cyan

if ($Config.GenerateCSV) {
    $csvPath = Join-Path $Config.OutputDirectory "$baseFileName.csv"
    Export-ReportToCSV -ReportData $reportData -OutputPath $csvPath
}

if ($Config.GenerateTXT) {
    $txtPath = Join-Path $Config.OutputDirectory "$baseFileName.txt"
    Export-ReportToText -ReportData $reportData `
                        -OutputPath $txtPath `
                        -CustomerName $Config.CustomerName
}

# Vis oppsummering
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OPPSUMMERING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Lisenstyper prosessert: $($allSKUs.Count)" -ForegroundColor White
Write-Host "Selskaper: $($Config.Companies.Count)" -ForegroundColor White
Write-Host "Totale datarader: $($reportData.Count)" -ForegroundColor White

# Vis total lisensfordeling
Write-Host "`nLisensfordeling:" -ForegroundColor Yellow
foreach ($company in $Config.Companies) {
    $companyTotal = ($reportData | Where-Object { $_.CompanyName -eq $company.Name } | 
                    Measure-Object -Property LicenseCount -Sum).Sum
    Write-Host "  $($company.Name): $companyTotal lisenser" -ForegroundColor White
}

Write-Host "`n✓ Skript fullført!" -ForegroundColor Green
Write-Host ""

#endregion