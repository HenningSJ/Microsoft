<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet Stig Kristiansen
Script av:      Kim Skog
============================================================================================
#>


#Koble fra eksisterende Microsoft Graph API
Disconnect-MgGraph
#Koble til Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"
#Hente lisensinformasjon om alle lisensene
#Get-MgSubscribedSku | Select-Object SkuPartNumber, ActiveUnits, ConsumedUnits
#Informasjon om en spesifik lisenstype
#Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object *
#SKU Partnumber = Navnet på lisensen

#Hente spesifikke lisenser
#Du kan filtrere lisensene slik:
#Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"

#Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId

#Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
#Exchange Online Plan 1
$PROJECTPROFESSIONAL = "53818b1b-4a27-454b-8896-0dba576410e6"
#Visio Plan 2
$VISIOCLIENT = "c5928f49-12ba-48f7-ada3-0d743a3601d5"
#Microsoft 365 Copilot
$Microsoft_365_Copilot = "639dec6b-bb19-468b-871c-c5c441c4b0cb"

#Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-Maskinentreprenør Stig Kristiansen.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til Maskinentreprenør Stig Kristiansen / Vacumkjempen pr $Today" | out-file -append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII



#Sjekket antall lisenser og utildelte lisenser i tenanten
$SPBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$SPBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$SPBUnassigned = $SPBLicensecount+$SPBUnassignedcount
$PROJLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "PROJECTPROFESSIONAL" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PROJUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "PROJECTPROFESSIONAL"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PROJUnassigned = $PROJLicensecount+$PROJUnassignedcount
$VIS2Licensecount = Get-MgSubscribedSku  | Where-Object { $_.SkuPartNumber -eq "VISIOCLIENT" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$VIS2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "VISIOCLIENT"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$VIS2Unassigned = $VIS2Licensecount+$VIS2Unassignedcount
$Microsoft_365_CopilotLicensecount = Get-MgSubscribedSku  | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$Microsoft_365_CopilotUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$Microsoft_365_CopilotUnassigned = $Microsoft_365_CopilotLicensecount+$Microsoft_365_CopilotUnassignedcount

#Lister opp totalt antall lisenser på kunde
write-output "Microsoft 365 Business Premium = Kunde har totalt $SPBLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $SPBUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Planner and Project Plan 3 = Kunde har totalt $PROJLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Planner and Project Plan 3 = Kunde har $PROJUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Visio Plan 2 = Kunde har totalt $VIS2Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Visio Plan 2 = Kunde har $VIS2Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Microsoft 365 Copilot = Kunde har totalt $Microsoft_365_CopilotLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Copilot = Kunde har $Microsoft_365_CopilotUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Opptelling av antall lisenser pr firma
#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Business Premium-lisens for Maskinentreprenør Stig Kristiansen
#Ekstra lisens på seritadmin@stigkristiansen.onmicrosoft.com
$MSKM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKM365BP = @($MSKM365BPlisens).Count+1
# Hent brukere med SPB-lisens for Vacumkjempen
$VACM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACM365BP = @($VACM365BPlisens).Count
# Skriv resultatene til fil
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKM365BP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACM365BP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Opptelling av antall lisenser pr firma
#Planner and Project Plan 3
Write-Output "Planner and Project Plan 3" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Planner and Project Plan 3-lisens for Maskinentreprenør Stig Kristiansen
$MSKPROJlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKPROJ = @($MSKPROJlisens).Count
# Hent brukere med Planner and Project Plan 3-lisens for Vacumkjempen
$VACPROJlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACPROJ = @($VACPROJlisens).Count
# Skriv resultatene til fil
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKPROJ" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACPROJ" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Opptelling av antall lisenser pr firma
#Visio Plan 2
Write-Output "Visio Plan 2" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Visio Plan 2-lisens for Maskinentreprenør Stig Kristiansen
$MSKVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKVIS2 = @($MSKVIS2lisens).Count
# Hent brukere med SPB-lisens for Vacumkjempen
$VACVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACVIS = @($VACVIS2lisens).Count
# Skriv resultatene til fil
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKVIS2" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACVIS" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Copilot
Write-Output "Microsoft 365 Copilot" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Copilot-lisens for Maskinentreprenør Stig Kristiansen
$MSKCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKCopilot = @($MSKCopilotlisens).Count
# Hent brukere med Microsoft 365 Copilot-lisens for Vacumkjempen
$VACCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACCopilot = @($VACCopilotlisens).Count
# Skriv resultatene til fil
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKCopilot" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACCopilot" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

