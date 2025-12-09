
$policyName = "Viva Test"

# Mest vanlig: App Setup Policy (der Viva Connections er pinned)
$usersAppSetup = Get-CsOnlineUser -Filter "TeamsAppSetupPolicy -eq '$policyName'"
$usersAppSetup | Select DisplayName, UserPrincipalName, TeamsAppSetupPolicy | Format-Table

# Hvis det i stedet er en App Permission Policy:
$usersAppPerm = Get-CsOnlineUser -Filter "TeamsAppPermissionPolicy -eq '$policyName'"
$usersAppPerm | Select DisplayName, UserPrincipalName, TeamsAppPermissionPolicy | Format-Table
