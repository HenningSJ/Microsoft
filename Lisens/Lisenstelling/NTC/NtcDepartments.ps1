#Koble fra eksisterende Microsoft Graph API
Disconnect-MgGraph

#Koble til Microsoft Graph API
$TenantId = "8e5367a7-2ca1-49d1-978c-8c5c56aa874d"
$ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
$CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"

Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertThumbprint

# Hent alle brukere med relevante felter
$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,Department,CompanyName"

# Definer grupper
$departments = @("NTC", "Romsdalen", "Fjellheisen AS", "Sommarøy Arctic Hotel AS", "Arctic Train AS")
$companies   = @("Snowhotel Kirkenes", "Snow Resort Kirkenes")

# Filtrer brukere
$filteredUsers = $users | Where-Object {
    ($departments -contains $_.Department) -or ($companies -contains $_.CompanyName)
}

# Tell antall per selskap
$grouped = $filteredUsers | Group-Object {
    if ($departments -contains $_.Department) {
        $_.Department
    } elseif ($companies -contains $_.CompanyName) {
        $_.CompanyName
    } else {
        "Ukjent"
    }
}

# Skriv ut antall per gruppe
Write-Host "Antall brukere per selskap:"
foreach ($group in $grouped) {
    Write-Host "$($group.Name): $($group.Count)"
}

# Totalt antall
Write-Host "`nTotalt antall brukere: $($filteredUsers.Count)"
