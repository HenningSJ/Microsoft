<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet NT Entreprenør tenanten
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
$FilePath = "C:\temp\O365Users-NT Entreprenør.txt"

Remove-Item -Path "$FilePath" -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til NT Entreprenør pr $Today" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Setter variabler for software ObjectID 

#Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
#Exchange Online Plan 2
$EXCHANGEENTERPRISE = "19ec0d23-8335-4cbd-94ac-6050e30712fa"
#Exchange Online Plan 1
$EXCHANGESTANDARD = "4b9405b0-7788-4568-add1-99614e613b69"
#Project-Abonnement 3
$PROJECTPROFESSIONAL = "53818b1b-4a27-454b-8896-0dba576410e6"

#Microsoft 365 Business Premium
$M365BPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365BPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365BPUnassigned = $M365BPLicensecount+$M365BPUnassignedcount
#Exchange Online Plan 1
$EXO1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO1Unassigned = $EXO1Licensecount+$EXO1Unassignedcount
#Exchange Online Plan 2
$EXO2Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGEENTERPRISE" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGEENTERPRISE"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO2Unassigned = $EXO2Licensecount+$EXO2Unassignedcount
#Project Plan 3
$ProjectP3Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "PROJECTPROFESSIONAL" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$ProjectP3Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "PROJECTPROFESSIONAL"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$ProjectP3Unassigned = $ProjectP3Licensecount+$ProjectP3Unassignedcount
#Visio
$VISLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "VISIOCLIENT" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$VISUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "VISIOCLIENT"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$VISUnassigned = $VISLicensecount+$VISUnassignedcount

#Lister opp totalt antall lisenser på kunde

write-output "Microsoft 365 Business Premium = Kunde har totalt $M365BPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $M365BPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Exchange Online Plan 1 = Kunde har totalt $EXO1Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXO1Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Exchange Online Plan 2 = Kunde har totalt $EXO2Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 2 = Kunde har $EXO2Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Project-Abonnement 3 = Kunde har totalt $ProjectP3Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Project-Abonnement 3 = Kunde har $ProjectP3Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Visio Plan 2 = Kunde har totalt $VISLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Visio Plan 2 = Kunde har $VISUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | out-file -append "$FilePath" -Encoding UTF8
#NT Entreprenør
$NTEntreprenorM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*ntentreprenor.no") } | Select-Object DisplayName, UserPrincipalName
$NTEntreprenorM365BP = @($NTEntreprenorM365BPlisens).count
$NTEntreprenorM365BP
#NT Byggservice
$NTByggserviceM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*ntbyggservice.no") } | Select-Object DisplayName, UserPrincipalName
$NTByggserviceM365BP = @($NTByggserviceM365BPlisens).count
$NTByggserviceM365BP
#NT Eiendom
$NTEiendomM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*nteiendom.no") } | Select-Object DisplayName, UserPrincipalName

$NTEiendomM365BP = @($NTEiendomM365BPlisens).count
$NTEiendomM365BP
Write-Output "NT Entreprenør: $NTEntreprenorM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Byggservice: $NTByggserviceM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Eiendom: $NTEiendomM365BP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | out-file -append "$FilePath" -Encoding UTF8
#NT Entreprenør
$NTEntreprenorEXOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*ntentreprenor.no") } | Select-Object DisplayName, UserPrincipalName
$NTEntreprenorEXOP = @($NTEntreprenorEXOPlisens).count
#NT Byggservice
$NTByggserviceEXOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*ntbyggservice.no") } | Select-Object DisplayName, UserPrincipalName
$NTByggserviceEXOP = @($NTByggserviceEXOPlisens).count
#NT Eiendom
$NTEiendomEXOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*nteiendom.no") } | Select-Object DisplayName, UserPrincipalName
$NTEiendomEXOP = @($NTEiendomEXOPlisens).count
Write-Output "NT Entreprenør: $NTEntreprenorEXOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Byggservice: $NTByggserviceEXOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Eiendom: $NTEiendomEXOP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Exchange Online Plan 2
Write-Output "Exchange Online Plan 2" | out-file -append "$FilePath" -Encoding UTF8
#NT Entreprenør
$NTEntreprenorEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGEENTERPRISE }) -and ($_.UserPrincipalName -like "*ntentreprenor.no") } | Select-Object DisplayName, UserPrincipalName
$NTEntreprenorEXOP2 = @($NTEntreprenorEXOP2lisens).count
#NT Byggservice
$NTByggserviceEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGEENTERPRISE }) -and ($_.UserPrincipalName -like "*ntbyggservice.no") } | Select-Object DisplayName, UserPrincipalName
$NTByggserviceEXOP2 = @($NTByggserviceEXOP2lisens).count
#NT Eiendom
$NTEiendomEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGEENTERPRISE }) -and ($_.UserPrincipalName -like "*nteiendom.no") } | Select-Object DisplayName, UserPrincipalName
$NTEiendomEXOP2 = @($NTEiendomEXOP2lisens).count
Write-Output "NT Entreprenør: $NTEntreprenorEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Byggservice: $NTByggserviceEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Eiendom: $NTEiendomEXOP2" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Project-abonnement 3
Write-Output "Project-abonnement 3" | out-file -append "$FilePath" -Encoding UTF8
#NT Entreprenør
$NTEntreprenorProject3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*ntentreprenor.no") } | Select-Object DisplayName, UserPrincipalName
$NTEntreprenorProject3 = @($NTEntreprenorProject3lisens).count
#NT Byggservice
$NTByggserviceProject3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*ntbyggservice.no") } | Select-Object DisplayName, UserPrincipalName
$NTByggserviceProject3 = @($NTByggserviceProject3lisens).count
#NT Eiendom
$NTEiendomProject3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*nteiendom.no") } | Select-Object DisplayName, UserPrincipalName
$NTEiendomProject3 = @($NTEiendomProject3lisens).count
Write-Output "NT Entreprenør: $NTEntreprenorProject3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Byggservice: $NTByggserviceProject3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Eiendom: $NTEiendomProject3" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Visio Plan 2
Write-Output "Visio Plan 2" | Out-File -Append $FilePath -Encoding UTF8
#NT Entreprenør
$NTEntreprenorVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT })-and $_.Department -eq "BPA" } | Select-Object DisplayName, UserPrincipalName
$NTEntreprenorVIS2 = @($NTEntreprenorVIS2lisens).Count
#NT Byggservice
$NTByggserviceVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT })-and $_.Department -eq "Hemis" } | Select-Object DisplayName, UserPrincipalName
$NTByggserviceVIS2 = @($NTByggserviceVIS2lisens).Count
#NT Eiendom
$nteiendomVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT })-and $_.Department -eq "Eiendom" } | Select-Object DisplayName, UserPrincipalName
$nteiendomVIS2 = @($nteiendomVIS2lisens).Count
# Skriv resultatene til fil
Write-Output "NT Entreprenør: $NTEntreprenorVIS2" | out-file -append $FilePath -Encoding UTF8
Write-Output "NT Byggservice: $NTByggserviceVIS2" | out-file -append $FilePath -Encoding UTF8
Write-Output "NT Eiendom: $nteiendomVIS2" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Summerer lisenser som inkludererer Exchange Online service
$NTEBackup = $NTEntreprenorEXOP+$NTEntreprenorM365BP
$NTBBackup = $NTByggserviceEXOP+$NTByggserviceM365BP
$NTEiendomBackup = $NTEiendomEXOP+$NTEiendomM365BP

Write-Output "Standard Backup for Office365" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Entreprenør: $NTEBackup" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Byggservice: $NTBBackup" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "NT Eiendom: $NTEiendomBackup" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

<#
#Sender epost med vedlegget
$EmailTo = "kim.skog@tromso.serit.no"
$EmailFrom = "noreply@itpartner.no"
$Subject = "Oversikt over alle lisenser hos NT Entreprenør (Nord-Tre) pr $Today" 
$Body = "Oversikt over alle lisenser hos NT Entreprenør (Nord-Tre)" 
$SMTPServer = "smtpgw.itpartner.no" 
$filenameAndPath = "$FilePath"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
$SMTPMessage.Attachments.Add($attachment)
$SMTPmessage.Cc.Add("aleksander.simonsen@tromso.serit.no")
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 465) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("itpartner_print", "S0mmerflorT21%"); 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
$SMTPClient.Send($SMTPMessage)
#>