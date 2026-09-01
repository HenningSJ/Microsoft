Connect-MgGraph -Scopes User.Read.All,Organization.Read.All

# Krever:
# Connect-MgGraph -Scopes User.Read.All,Organization.Read.All

$ExportPath = "C:\Temp\M365-Lisensrapport.csv"

Write-Host "Henter lisensinformasjon..." -ForegroundColor Cyan

# Hent alle tenant-lisenser
$SubscribedSkus = Get-MgSubscribedSku

# Lag oppslagstabell SKU-ID -> Lisensnavn
$SkuLookup = @{}

foreach ($Sku in $SubscribedSkus) {
    $SkuLookup[$Sku.SkuId] = $Sku.SkuPartNumber
}

Write-Host "Henter brukere..." -ForegroundColor Cyan

$Users = Get-MgUser -All -Property `
    DisplayName,
    UserPrincipalName,
    Department,
    CompanyName,
    UsageLocation,
    AccountEnabled,
    AssignedLicenses

$Report = foreach ($User in $Users) {

    if ($User.AssignedLicenses.Count -eq 0) {

        [PSCustomObject]@{
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            License           = "NO_LICENSE"
        }

        continue
    }

    foreach ($AssignedLicense in $User.AssignedLicenses) {

        [PSCustomObject]@{
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            License           = $SkuLookup[$AssignedLicense.SkuId]
        }
    }
}

$Report |
    Sort-Object DisplayName |
    Export-Csv $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Rapport eksportert til:" -ForegroundColor Green
Write-Host $ExportPath