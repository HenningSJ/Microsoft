# Importer Microsoft Graph-modulen
#Import-Module Microsoft.Graph

# Logg inn med nødvendige rettigheter
#Connect-MgGraph -Scopes "User.Read.All"

# Finn SKU-ID for Microsoft 365 F1 EEA (no Teams)
$sku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_F1_EEA_(no_Teams)" }

if (-not $sku) {
    Write-Host "❌ Fant ikke SKU for Microsoft_365_F1_EEA_(no_Teams). Sjekk med Get-MgSubscribedSku."
    exit
}

$skuId = $sku.SkuId
Write-Host "Bruker SKU-ID: $skuId"

# Les brukere fra CSV
$users = Import-Csv "C:\Temp\Users.csv"

foreach ($user in $users) {
    try {
        Write-Host "Sjekker lisens for $($user.UserPrincipalName)..."
        $licenses = Get-MgUserLicenseDetail -UserId $user.UserPrincipalName

        if ($licenses.SkuId -contains $skuId) {
            Write-Host "✅ $($user.UserPrincipalName) har riktig SKU tildelt."
        }
        else {
            Write-Host "❌ $($user.UserPrincipalName) har IKKE riktig SKU."
        }
    }
    catch {
        Write-Host "⚠️ Feil ved sjekk for $($user.UserPrincipalName): $_"
    }
}
