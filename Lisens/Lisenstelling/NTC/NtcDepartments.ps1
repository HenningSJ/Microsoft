Connect-MgGraph -Scopes "User.Read.All"

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
