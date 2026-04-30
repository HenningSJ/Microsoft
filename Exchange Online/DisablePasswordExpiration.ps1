install-module microsoft.graph

Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.Read.All"

Update-MgUser -UserId moterom@tromsotaxi.no -PasswordPolicies DisablePasswordExpiration

#Sjekke at det fungerer:
Get-MgUser -UserId moterom@tromsotaxi.no -Property PasswordPolicies | Select-Object -Property UserPrincipalName, PasswordPolicies