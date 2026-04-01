
#Koble til Microsoft Graph API
$TenantId = "8e5367a7-2ca1-49d1-978c-8c5c56aa874d"
$ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
$CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"

Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertThumbprint

# Hent alle brukere med relevante felter
$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,Department,CompanyName,UserType,AssignedLicenses"

# Definer verdier som skal inkluderes
$departments = @("NTC", "Romsdalen", "Fjellheisen AS", "Sommarøy Arctic Hotel AS", "Arctic Train AS")
$companies   = @("Snowhotel Kirkenes", "Snow Resort Kirkenes")

# Filtrer brukere som IKKE har disse verdiene, IKKE er gjester og HAR minst én lisens
$excludedUsers = $users | Where-Object {
    -not (($departments -contains $_.Department) -or ($companies -contains $_.CompanyName)) -and
    $_.UserType -ne "Guest" -and
    ($_.AssignedLicenses.Count -gt 0)
}

# Skriv ut antall og liste
Write-Host "Antall brukere som IKKE tilhører noen av de angitte selskapene (uten gjester og uten lisensløse): $($excludedUsers.Count)"
Write-Host "`nListe over brukere:"
$excludedUsers | Select-Object DisplayName, UserPrincipalName, Department, CompanyName | Format-Table