<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet HPNN tenanten
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

#Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-HPNN.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til HPNN pr $Today" | out-file -append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#region SKUID
#SKU ID til produktene
#Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
#Exchange Online Plan 1
$EXCHANGESTANDARD = "4b9405b0-7788-4568-add1-99614e613b69"
#Powerapps Premium
$POWERAPPS_PER_USER = "b30411f5-fea1-4a59-9ad9-3db7c7ead579"
#Power Automate Premium
$POWERAUTOMATE_ATTENDED_RPA = "eda1941c-3c4f-4995-b5eb-e85a42175ab9"
#Visio Plan 2
$VISIOCLIENT = "c5928f49-12ba-48f7-ada3-0d743a3601d5"
#Power BI Pro
$POWER_BI_PRO = "f8a1db68-be16-40ed-86d5-cb42ce701560"
#Microsoft 365 Copilot
$Microsoft_365_Copilot = "639dec6b-bb19-468b-871c-c5c441c4b0cb"
#endregion

#region aktive og utildelte lisenser i tenant
#Sjekket antall lisenser og utildelte lisenser i tenanten
$SPBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$SPBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$SPBUnassigned = $SPBLicensecount+$SPBUnassignedcount
$EXOP1Licensecount = Get-MgSubscribedSku  | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXOP1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXOP1Unassigned = $EXOP1Licensecount+$EXOP1Unassignedcount
$PAPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "POWERAPPS_PER_USER" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PAPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "POWERAPPS_PER_USER"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PAPUnassigned = $PAPLicensecount+$PAPUnassignedcount
$PAULicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "POWERAUTOMATE_ATTENDED_RPA" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PAUUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "POWERAUTOMATE_ATTENDED_RPA"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PAUUnassigned = $PAULicensecount+$PAUUnassignedcount
$VISLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "VISIOCLIENT" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$VISUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "VISIOCLIENT"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$VISUnassigned = $VISLicensecount+$VISUnassignedcount
$PBILicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "POWER_BI_PRO" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PBIUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "POWER_BI_PRO"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PBIUnassigned = $PBILicensecount+$PBIUnassignedcount
$COPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$COPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$COPUnassigned = $COPLicensecount+$COPUnassignedcount
#endregion

#region Output antall lisenser
#Lister opp totalt antall lisenser på kunde
write-output "Microsoft 365 Business Premium = Kunde har totalt $SPBLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $SPBUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Exchange Online Plan 1 = Kunde har totalt $EXOP1Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXOP1Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Power Apps Premium = Kunde har totalt $PAPLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Power Apps Premium = Kunde har $PAPUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Power Automate Premium = Kunde har totalt $PAULicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Power Automate Premium = Kunde har $PAUUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Visio Plan 2 = Kunde har totalt $VISLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Visio Plan 2 = Kunde har $VISUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Power BI Pro = Kunde har totalt $PBILicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Power BI Pro = Kunde har $PBIUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Microsoft 365 Copilot = Kunde har totalt $COPLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Copilot = Kunde har $COPUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
#endregion

#region Output lisenser pr firma
#Opptelling av antall lisenser pr firma

#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Business Premium-lisens for BPA Nord
$BPAM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAM365BP = @($BPAM365BPlisens).Count
# Hent brukere med SPB-lisens for Hemis
$HemisM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisM365BP = @($HemisM365BPlisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAM365BP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisM365BP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Exchange Online Plan 1-lisens for BPA Nord
$BPAEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAEXO1 = @($BPAEX01lisens).Count+2
# Hent brukere med Exchange Online Plan 1-lisens for Hemis
$HemisEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisEXO1 = @($HemisEXO1lisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAEXO1" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisEXO1" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Power Automate Premium
Write-Output "Power Automate Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Power Automate Premium-lisens for BPA Nord
$BPAPAUPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWERAUTOMATE_ATTENDED_RPA })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAPAUP = @($BPAPAUPlisens).Count
# Hent brukere med Power Automate Premium-lisens for Hemis
$HemisPAUPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWERAUTOMATE_ATTENDED_RPA })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisPAUP = @($HemisPAUPlisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAPAUP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisPAUP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Powerapps Premium
Write-Output "Powerapps Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Powerapps Premium-lisens for BPA Nord
$BPAPAPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWERAPPS_PER_USER })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAPAP = @($BPAPAPlisens).Count
# Hent brukere med Powerapps Premium-lisens for Hemis
$HemisPAPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWERAPPS_PER_USER })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisPAP = @($HemisPAPlisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAPAP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisPAP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Visio Plan 2
Write-Output "Visio Plan 2" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Visio Plan 2-lisens for BPA Nord
$BPAVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAVIS2 = @($BPAVIS2lisens).Count
# Hent brukere med Visio Plan 2-lisens for Hemis
$HemisVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisVIS2 = @($HemisVIS2lisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAVIS2" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisVIS2" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Power BI Pro
Write-Output "Power BI Pro" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Power BI Pro-lisens for BPA Nord
$BPAPBIlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWER_BI_PRO })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPAPBI = @($BPAPBIlisens).Count
# Hent brukere med Power BI Pro-lisens for Hemis
$HemisPBIlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $POWER_BI_PRO })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisPBI = @($HemisPBIlisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPAPBI" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisPBI" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Microsoft 365 Copilot
Write-Output "Microsoft 365 Copilot" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Copilot-lisens for BPA Nord
$BPACOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$BPACOP = @($BPACOPlisens).Count
# Hent brukere med Microsoft 365 Copilot-lisens for Hemis
$HemisCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$HemisCOP = @($HemisCOPlisens).Count
# Skriv resultatene til fil
Write-Output "BPA Nord: $BPACOP" | out-file -append $FilePath -Encoding UTF8
Write-Output "Hemis: $HemisCOP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
#endregion

#region Output Backuptjeneste
#Summerer lisenser som inkludererer Exchange Online service
$BPABackup = $BPAEXO1+$BPAM365BP
$HEMISBackup = $HemisEXO1+$HemisM365BP

Write-Output "Standard Backup for Office365" | out-file -append $FilePath -Encoding UTF8
Write-Output "BPA: $BPABackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "HEMIS: $HEMISBackup" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Serit Sikker Epost" | out-file -append $FilePath -Encoding UTF8
Write-Output "BPA: $BPABackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "HEMIS: $HEMISBackup" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
#endregion

Write-Output "FORDELING AV HEMIS SINE LISENSER FORDELT PÅ LOKASJONER" | out-file -append $FilePath -Encoding UTF8

#region Lager liste over brukere i Administrasjonen
#Lisenser på disse brurkerne skal ikke faktureres Tromsø eller Bodø, men Administrasjonen
#Linda Rossvoll
#Trond Løkholm Halvorsen
#Kristin Fagerheim
#Magnus Arkteg
$AdmUsers = @("linda.rossvoll@hemis.no", "trond.halvorsen@Hemis.no", "kristin.fagerheim@hemis.no", "magnus.arkteg@Hemis.no")
$Administrasjonen = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object { $_.UserPrincipalName -in $AdmUsers } | Select-Object DisplayName, UserPrincipalName
#Lager array av Oslobrukere
$AdmUPNs = $Administrasjonen.UserPrincipalName

#Lager filter ansatte i administrasjonen
$AdmCopilot = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $AdmUPNs -and $_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot} | Select-Object DisplayName, UserPrincipalName
$AdmCopilotcount = @($AdmCopilot).Count
$AdmM365BP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $AdmUPNs -and $_.AssignedLicenses.SkuId -contains $SPB} | Select-Object DisplayName, UserPrincipalName
#(Ekstra Business Premiumlisenserseritadmin@hpnnas.onmicrosoft.com, service.hemis@Hemis.no og serittest@hpnnas.onmicrosoft.com)
$AdmM365BPcount = @($AdmM365BP).Count+3
$AdmEX01 = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $AdmUPNs -and $_.AssignedLicenses.SkuId -contains $EXCHANGESTANDARD} | Select-Object DisplayName, UserPrincipalName
#Ekstra Exchange Onlinelisenser (hemis.arkivadmin@hpnnas.onmicrosoft.com, hemis@Hemis.no og noreply@Hemis.no)
$AdmEX01count = @($AdmEX01).Count+3
$AdmPAUP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $AdmUPNs -and $_.AssignedLicenses.SkuId -contains $POWERAUTOMATE_ATTENDED_RPA} | Select-Object DisplayName, UserPrincipalName
$AdmPAUPcount = @($AdmPAUP).Count
$AdmPAP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $AdmUPNs -and $_.AssignedLicenses.SkuId -contains $POWERAPPS_PER_USER} | Select-Object DisplayName, UserPrincipalName
$AdmPAPcount = @($AdmPAP).Count+1
#endregion 

#region Lisenser fordelt på lokajon
#Microsoft 365 Business Premium
$HEMTOSBP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $SPB})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Tromsø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMTOSBPCount = @($HEMTOSBP).count
$HEMBODBP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $SPB})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Bodø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMBODBPCount = @($HEMBODBP).count
$HEMALTBP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $SPB})-and $_.Department -eq "Hemis" -and ($_.OfficeLocation -eq "Alta" -or ($_.OfficeLocation -eq "Finnmark")) -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMALTBPCount = @($HEMALTBP).count
$HEMVESTBP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $SPB})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Vesterålen"} | Select-Object DisplayName, UserPrincipalName, Department
$HEMVESTBPCount = @($HEMVESTBP).count
#Exchange Online Plan 1
$HEMTOSEX = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $EXCHANGESTANDARD})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Tromsø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMTOSEXPCount = @($HEMTOSEX).count
$HEMBODEX = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $EXCHANGESTANDARD})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Bodø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMBODEXCOUNT = @($HEMBODEX).count
$HEMALTEX = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $EXCHANGESTANDARD})-and $_.Department -eq "Hemis" -and ($_.OfficeLocation -eq "Alta" -or ($_.OfficeLocation -eq "Finnmark")) -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMALETXCount = @($HEMALTEX).count
$HEMVESTEX = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $EXCHANGESTANDARD})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Vesterålen" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMVESTEXCount = @($HEMVESTEX).count
#Microsoft Copilot for M365
$HEMTOSCOP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $Microsoft_365_Copilot})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Tromsø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMTOSCOPCount = @($HEMTOSCOP).count
$HEMBODCOP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $Microsoft_365_Copilot})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Bodø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMBODCOPCount = @($HEMBODCOP).count
$HEMALTCOP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $Microsoft_365_Copilot})-and $_.Department -eq "Hemis" -and ($_.OfficeLocation -eq "Alta" -or ($_.OfficeLocation -eq "Finnmark")) -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMALTCOPCount = @($HEMALTCOP).count
$HEMVESTCOP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $Microsoft_365_Copilot})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Vesterålen" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMVESTCOPCount = @($HEMVESTCOP).count
#Power Apps Premium
$HEMTOSPAPU = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAPPS_PER_USER})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Tromsø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMTOSPAPUCount = @($HEMTOSPAPU).count
$HEMBODPAPU = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAPPS_PER_USER})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Bodø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMBODPAPUCount = @($HEMBODPAPU).count
$HEMALTPAPU = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAPPS_PER_USER})-and $_.Department -eq "Hemis" -and ($_.OfficeLocation -eq "Alta" -or ($_.OfficeLocation -eq "Finnmark")) -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMALTPAPUCount = @($HEMALTPAPU).count
$HEMVESTPAPU = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAPPS_PER_USER})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Vesterålen" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMVESTPAPUCount = @($HEMVESTPAPU).count
#Power Automate Premium
$HEMTOSPAP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAUTOMATE_ATTENDED_RPA})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Tromsø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMTOSPAPCount = @($HEMTOSPAP).count+1
$HEMBODPAP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAUTOMATE_ATTENDED_RPA})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Bodø" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMBODPAPCount = @($HEMBODPAP).count
$HEMALTPAP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAUTOMATE_ATTENDED_RPA})-and $_.Department -eq "Hemis" -and ($_.OfficeLocation -eq "Alta" -or ($_.OfficeLocation -eq "Finnmark")) -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMALTPAPCount = @($HEMALTPAP).count
$HEMVESTPAP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department,OfficeLocation" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -match $POWERAUTOMATE_ATTENDED_RPA})-and $_.Department -eq "Hemis" -and $_.OfficeLocation -eq "Vesterålen" -and $_.UserPrincipalName -notin $AdmUsers} | Select-Object DisplayName, UserPrincipalName, Department
$HEMVESTPAPCount = @($HEMVESTPAP).count
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
#endregion

Write-Output "LISENSFORDELING HEMIS" | out-file -append $FilePath -Encoding UTF8
Write-Output "Microsoft 365 Business Premium" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmM365BPcount (seritadmin@hpnnas.onmicrosoft.com, service.hemis@Hemis.no og serittest@hpnnas.onmicrosoft.com)" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $HEMTOSBPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $HEMBODBPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $HEMALTBPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $HEMVESTBPCount" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Exchange Online Plan 1" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmEX01count (hemis.arkivadmin@hpnnas.onmicrosoft.com, hemis@Hemis.no og noreply@Hemis.no) " | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $HEMTOSEXPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $HEMBODEXCOUNT" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $HEMALETXCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $HEMVESTEXCount" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Microsoft Copilot for M365" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmCopilotcount " | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $HEMTOSCOPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $HEMBODCOPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $HEMALTCOPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $HEMVESTCOPCount" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Power Apps Premium" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmPAPcount (seritadmin@hpnnas.onmicrosoft.com)" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $HEMTOSPAPUCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $HEMBODPAPUCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $HEMALTPAPUCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $HEMVESTPAPUCount" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Power Automate Premium" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmPAUPcount (service.hemis@Hemis.no)" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $HEMTOSPAPCount (service.hemis@Hemis.no)" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $HEMBODPAPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $HEMALTPAPCount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $HEMVESTPAPCount" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Summerer lisenser som inkludererer Exchange Online service
$AdmBackup = $AdmM365BPcount+$AdmEX01count
$TOSBackup = $HEMTOSBPCount+$HEMTOSEXPCount
$BODBackup = $HEMBODBPCount+$HEMBODEXCOUNT
$ALTBackup = $HEMALTBPCount+$HEMALETXCount
$VESTBackup = $HEMVESTBPCount+$HEMVESTEXCount

Write-Output "Standard Backup for Office365" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $TOSBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $BODBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $ALTBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $VESTBackup" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

Write-Output "Serit Sikker Epost" | out-file -append $FilePath -Encoding UTF8
Write-Output "Administrasjon: $AdmBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø: $TOSBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Bodø: $BODBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Alta: $ALTBackup" | out-file -append $FilePath -Encoding UTF8
Write-Output "Vesterålen: $VESTBackup" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
