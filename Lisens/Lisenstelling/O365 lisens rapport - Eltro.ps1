<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet Eltro
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

$POWERAPPS_PER_APP_IW = "bf666882-9c9b-4b2e-aa2f-4789b0a52ba2"
#Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
#Exchange Online Plan 1
$EXCHANGESTANDARD = "4b9405b0-7788-4568-add1-99614e613b69"
#Microsoft 365 Business Standard
$O365_BUSINESS_PREMIUM = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"
$M365_F1_COMM = "50f60901-3181-4b75-8a2c-4c8e4c1d5a72"
$EXCHANGEENTERPRISE = "19ec0d23-8335-4cbd-94ac-6050e30712fa"
$POWERAPPS_PER_APP = "a8ad7d2b-b8cf-49d6-b25a-69094a0be206"

#Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-Eltro.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til Eltro pr $Today" | out-file -append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII



#Sjekket antall lisenser og utildelte lisenser i tenanten
$SPBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$SPBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$SPBUnassigned = $SPBLicensecount+$SPBUnassignedcount
$O365BSLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "O365_BUSINESS_PREMIUM" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$O365BSUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "O365_BUSINESS_PREMIUM"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$O365BSUnassigned = $O365BSLicensecount+$O365BSUnassignedcount
$EXOP1Licensecount = Get-MgSubscribedSku  | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXOP1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXOP1Unassigned = $EXOP1Licensecount+$EXOP1Unassignedcount
$EXOP2Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGEENTERPRISE" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXOP2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGEENTERPRISE"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXOP2Unassigned = $EXOP2Licensecount+$EXOP2Unassignedcount
$F1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "M365_F1_COMM" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$F1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "M365_F1_COMM"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$F1Unassigned = $F1Licensecount+$F1Unassignedcount
$PAPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "POWERAPPS_PER_APP" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PAPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "POWERAPPS_PER_APP"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PAPUnassigned = $PAPUnassignedcount


#Lister opp totalt antall lisenser på kunde
write-output "Microsoft 365 Business Premium = Kunde har totalt $SPBLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $SPBUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Microsoft 365 Business Standard = Kunde har totalt $O365BSLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Business Standard = Kunde har $O365BSUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Exchange Online Plan 1 = Kunde har totalt $EXOP1Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXOP1Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Exchange Online Plan 2 = Kunde har totalt $EXOP2Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Exchange Online Plan 2 = Kunde har $EXOP2Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Microsoft 365 F1 = Kunde har totalt $F1Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 F1 = Kunde har $F1Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Power Apps per app plan = Kunde har totalt $PAPLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Opptelling av antall lisenser pr firma
#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Business Premium-lisens for Eltro
$EltroM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@eltro.no") } | Select-Object DisplayName, UserPrincipalName
$EltroM365BP = @($EltroM365BPlisens).Count
# Hent brukere med SPB-lisens for Eltro VVS
$EltroVVSM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@eltrovvs.no") } | Select-Object DisplayName, UserPrincipalName
$EltroVVSM365BP = @($EltroVVSM365BPlisens).Count
# Skriv resultatene til fil
Write-Output "Eltro: $EltroM365BP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Eltro VVS: $EltroVVSM365BP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Microsoft 365 Business Standard
Write-Output "Microsoft 365 Business Standard" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Business Standard-lisens for Eltro
#Inkluderer seritadminkonto
$EltroMS365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $O365_BUSINESS_PREMIUM }) -and ($_.UserPrincipalName -like "*@eltro.no") } | Select-Object DisplayName, UserPrincipalName
$EltroMS365BS = @($EltroMS365BSlisens).Count+1
# Hent brukere med SPB-lisens for Eltro VVS
$EltroVVSMS365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $O365_BUSINESS_PREMIUM }) -and ($_.UserPrincipalName -like "*@eltrovvs.no") } | Select-Object DisplayName, UserPrincipalName
$EltroVVSMS365BS = @($EltroVVSMS365BSlisens).Count
# Skriv resultatene til fil
Write-Output "Eltro: $EltroMS365BS" | out-file -append $FilePath -Encoding UTF8
Write-Output "Eltro VVS: $EltroVVSMS365BS" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Exchange Online Plan 1-lisens for Eltro
$EltroEXOP1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*@eltro.no") } | Select-Object DisplayName, UserPrincipalName
$EltroEXOP1 = @($EltroEXOP1lisens).Count
# Hent brukere med SPB-lisens for Eltro VVS
$EltroVVSEXOP1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*@eltrovvs.no") } | Select-Object DisplayName, UserPrincipalName
$EltroVVSEXOP1 = @($EltroVVSEXOP1lisens).Count
# Skriv resultatene til fil
Write-Output "Eltro: $EltroEXOP1" | out-file -append $FilePath -Encoding UTF8
Write-Output "Eltro VVS: $EltroVVSEXOP1" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Exchange Online Plan 2
Write-Output "Exchange Online Plan 2" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Exchange Online Plan 2-lisens for Eltro
$EltroEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGEENTERPRISE }) -and ($_.UserPrincipalName -like "*@eltro.no") } | Select-Object DisplayName, UserPrincipalName
$EltroEXOP2 = @($EltroEXOP2lisens).Count
# Hent brukere med SPB-lisens for Eltro VVS
$EltroVVSEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGEENTERPRISE }) -and ($_.UserPrincipalName -like "*@eltrovvs.no") } | Select-Object DisplayName, UserPrincipalName
$EltroVVSEXOP2 = @($EltroVVSEXOP2lisens).Count
# Skriv resultatene til fil
Write-Output "Eltro: $EltroEXOP2" | out-file -append $FilePath -Encoding UTF8
Write-Output "Eltro VVS: $EltroVVSEXOP2" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Microsoft 365 F1
Write-Output "Microsoft 365 F1" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 F1-lisens for Eltro
$EltroF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365_F1_COMM }) -and ($_.UserPrincipalName -like "*@eltro.no") } | Select-Object DisplayName, UserPrincipalName
$EltroF1 = @($EltroF1lisens).Count
# Hent brukere med SPB-lisens for Eltro VVS
$EltroVVSF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365_F1_COMM }) -and ($_.UserPrincipalName -like "*@eltrovvs.no") } | Select-Object DisplayName, UserPrincipalName
$EltroVVSF1 = @($EltroVVSF1lisens).Count
# Skriv resultatene til fil
Write-Output "Eltro: $EltroF1" | out-file -append $FilePath -Encoding UTF8
Write-Output "Eltro VVS: $EltroVVSF1" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Power Apps per app plan
Write-Output "Power Apps per app plan" | out-file -append $FilePath -Encoding UTF8
#Eltro
Write-Output "Eltro (tildelt tenanten): $PAPLicensecount" | out-file -append $FilePath -Encoding UTF8

"" | out-file -append $FilePath -Encoding ASCII
