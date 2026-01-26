Connect-MgGraph -Scopes "User.Read.All" -UseDeviceCode

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