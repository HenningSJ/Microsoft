# HPNN-LicenseReport.ps1

# Importer felles funksjoner
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"

# Konfigurasjon
$Config = @{
    TenantId = "5b2363ca-c61b-4340-bc99-efcab96c4df9"
    ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"
    CustomerName = "HPNN"

    Companies = @(
        @{ Name = "BPA Nord"; DepartmentFilter = "BPA" }
        @{ Name = "Hemis"; DepartmentFilter = "Hemis" }
    )

    HemisLocations = @(
        @{ Name = "Tromsø"; LocationFilter = "Tromsø" }
        @{ Name = "Bodø"; LocationFilter = "Bodø" }
        @{ Name = "Alta"; LocationFilter = "Alta" }
        @{ Name = "Vesterålen"; LocationFilter = "Vesterålen" }
    )

    AdministrationUsers = @(
        "linda.rossvoll@hemis.no",
        "trond.halvorsen@hemis.no",
        "kristin.fagerheim@hemis.no",
        "magnus.arkteg@hemis.no"
    )

    ExtraServiceAccounts = @{
        Admin  = @("seritadmin@hpnnas.onmicrosoft.com", "serittest@hpnnas.onmicrosoft.com")
        Tromso = @("service.hemis@hemis.no")
    }

    OutputDirectory = "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\HPNN"
    GenerateCSV = $true
    GenerateTXT = $true
    IncludeLocationBreakdown = $true
}

# Legg til tjenestekontoer i administrasjonslisten
$Config.AdministrationUsers += $Config.ExtraServiceAccounts.Admin

# Koble til Microsoft Graph
$connected = Connect-M365GraphAPI -TenantId $Config.TenantId `
                                  -ClientId $Config.ClientId `
                                  -CertThumbprint $Config.CertThumbprint

if (-not $connected) {
    Write-Error "Kunne ikke koble til Microsoft Graph. Avbryter skript."
    exit 1
}

# Hent SKUer
$allSKUs = Get-AllTenantSKUs
if ($allSKUs.Count -eq 0) {
    Write-Error "Ingen SKUer funnet i tenanten. Avbryter."
    exit 1
}

# Initier rapportdata
$reportData = @()
$locationReportData = @()

foreach ($skuId in $allSKUs.Keys) {
    $sku = $allSKUs[$skuId]
    $friendlyName = $sku.FriendlyName

    # Fordeling per selskap
    $companyDist = Get-LicenseCountByDepartment -SkuId $skuId -Companies $Config.Companies

    foreach ($company in $Config.Companies) {
        $reportData += [PSCustomObject]@{
            LicenseType       = $friendlyName
            SkuPartNumber     = $sku.SkuPartNumber
            SkuId             = $sku.SkuId
            CompanyName       = $company.Name
            LicenseCount      = $companyDist[$company.Name]
            TotalLicenses     = $sku.TotalLicenses
            ConsumedLicenses  = $sku.ConsumedLicenses
            AvailableLicenses = $sku.AvailableLicenses
            ReportDate        = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }

    # Lokasjonsfordeling for Hemis
    if ($Config.IncludeLocationBreakdown -and $companyDist["Hemis"] -gt 0) {
        $locDist = Get-LicenseCountByOfficeLocation -SkuId $skuId `
                     -DepartmentName "Hemis" `
                     -Locations $Config.HemisLocations `
                     -ExcludeUserPrincipals $Config.AdministrationUsers `
                     -IncludeAlternate @{'Alta' = @('Alta','Finnmark')}

        foreach ($acct in $Config.ExtraServiceAccounts.Tromso) {
            $user = Get-MgUser -Filter "userPrincipalName eq '$acct'" -Property AssignedLicenses
            if ($user.AssignedLicenses.SkuId -contains $skuId) {
                $locDist["Tromsø"] += 1
                Write-Host " +1 Tromsø for $friendlyName (servicekonto: $acct)" -ForegroundColor Yellow
            }
        }

        foreach ($acct in $Config.ExtraServiceAccounts.Admin) {
            $user = Get-MgUser -Filter "userPrincipalName eq '$acct'" -Property AssignedLicenses
            if ($user.AssignedLicenses.SkuId -contains $skuId) {
                Write-Host " (Admin servicekonto $acct har $friendlyName)" -ForegroundColor Yellow
            }
        }

        $adminCount = Get-AdministrationLicenseCount -SkuId $skuId -AdminUsers $Config.AdministrationUsers

        $locationReportData += [PSCustomObject]@{
            LicenseType   = $friendlyName
            SkuPartNumber = $sku.SkuPartNumber
            Location      = "Administrasjon"
            LicenseCount  = $adminCount
            ReportDate    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }

        foreach ($loc in $Config.HemisLocations) {
            $locationReportData += [PSCustomObject]@{
                LicenseType   = $friendlyName
                SkuPartNumber = $sku.SkuPartNumber
                Location      = $loc.Name
                LicenseCount  = $locDist[$loc.Name]
                ReportDate    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
    }
}

# Eksporter rapporter
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$baseFileName = "O365-Lisensrapport-HPNN-$timestamp"

if ($Config.GenerateCSV) {
    $csvPath = Join-Path $Config.OutputDirectory "$baseFileName.csv"
    Export-ReportToCSV -ReportData $reportData -OutputPath $csvPath

    if ($Config.IncludeLocationBreakdown) {
        $csvLocPath = Join-Path $Config.OutputDirectory "$baseFileName-Hemis-Lokasjoner.csv"
        Export-ReportToCSV -ReportData $locationReportData -OutputPath $csvLocPath
    }
}

if ($Config.GenerateTXT) {
    $txtPath = Join-Path $Config.OutputDirectory "$baseFileName.txt"
    Export-ReportToText -ReportData $reportData -OutputPath $txtPath -CustomerName $Config.CustomerName
}