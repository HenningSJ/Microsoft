# Importer Microsoft Graph-modulen
#Import-Module Microsoft.Graph

# Logg inn med nødvendige rettigheter
#Connect-MgGraph -Scopes "User.ReadWrite.All"

# Hent SKU-ID
#Get-MgSubscribedSku | Select SkuPartNumber, SkuId

$sku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_F1_EEA_(no_Teams)" }

if (-not $sku) {
    Write-Host "Fant ikke SKU for M365F1_EEA_NoTeams. Sjekk med Get-MgSubscribedSku."
    exit
}

$skuId = $sku.SkuId
Write-Host "Bruker SKU-ID: $skuId"

# Les brukere fra en CSV-fil (kolonne: UserPrincipalName)
$users = Import-Csv "C:\Temp\Users.csv"

foreach ($user in $users) {
    try {
        Write-Host "Tildeler lisens til $($user.UserPrincipalName)..."
        Set-MgUserLicense -UserId $user.UserPrincipalName -AddLicenses @{SkuId = $skuId} -RemoveLicenses @()
        Write-Host "✅ Lisens tildelt til $($user.UserPrincipalName)"
    }
    catch {
        Write-Host "❌ Feil ved tildeling til $($user.UserPrincipalName): $_"
    }
}
