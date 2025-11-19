<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet Storegga
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
$FilePath = "c:\temp\O365Users-Storegga.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til Storegga pr $Today" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Setter variabler for software ObjectID 

#Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
#Exchange Online Plan 1
$EXCHANGESTANDARD = "4b9405b0-7788-4568-add1-99614e613b69"
#Copilot
$COPILOT = "639dec6b-bb19-468b-871c-c5c441c4b0cb"
#OneDrive for business plan 2
$WACONEDRIVEENTERPRISE = "ed01faf2-1d88-4947-ae91-45ca18703a96"

#region Lister opp totalt antall lisenser pr subscription
#M365 Business Premium
$M365BPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365BPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365BPUnassigned = $M365BPLicensecount+$M365BPUnassignedcount

#Exchange Online Plan 1
$EXO1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO1Unassigned = $EXO1Licensecount+$EXO1Unassignedcount

#Microsoft 365 Copilot
$M365COPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365COPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365COPUnassigned = $M365COPLicensecount+$M365COPUnassignedcount
#endregion Lister opp totalt antall lisenser pr subscription

#Lister opp totalt antall lisenser på kunde
write-output "Microsoft 365 Business Premium = Kunde har totalt $M365BPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $M365BPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Exchange Online Plan 1 = Kunde har totalt $EXO1Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXO1Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Microsoft Copilot = Kunde har totalt $M365COPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft Copilot = Kunde har $M365COPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#region Lisenser pr selskap
#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | out-file -append "$FilePath" -Encoding UTF8
#Storegga Entreprenør
$ENTMS365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Entreprenør"} | Select-Object DisplayName, UserPrincipalName
$ENTMS365BP = @($ENTMS365BPlisens).count
#Storegga Betong
$BETMS365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Betong"} | Select-Object DisplayName, UserPrincipalName
$BETMS365BP = @($BETMS365BPlisens).count
Write-Output "Storegga Entreprenør: $ENTMS365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Storegga Betong: $BETMS365BP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | out-file -append "$FilePath" -Encoding UTF8
#Storegga Entreprenør
$ENTEX01lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $EXCHANGESTANDARD -and $_.Department -like "Entreprenør"} | Select-Object DisplayName, UserPrincipalName
#Ekstra lisens for printer@storeggagruppen.no
$ENTEX01 = @($ENTEX01lisens).count+1
#Storegga Betong
$BETEX01lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $EXCHANGESTANDARD -and $_.Department -like "Betong"} | Select-Object DisplayName, UserPrincipalName
$BETEX01 = @($BETEX01lisens).count
Write-Output "Storegga Entreprenør: $ENTEX01" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Storegga Betong: $BETEX01" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Microsoft Copilot
Write-Output "Microsoft Copilot" | out-file -append "$FilePath" -Encoding UTF8
#Storegga Entreprenør
$ENTCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $COPILOT -and $_.Department -like "Entreprenør"} | Select-Object DisplayName, UserPrincipalName
#Ekstra lisens for printer@storeggagruppen.no
$ENTCopilot = @($ENTCopilotlisens).count
#Storegga Betong
$BETCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $COPILOT -and $_.Department -like "Betong"} | Select-Object DisplayName, UserPrincipalName
$BETCopilot = @($BETCopilotlisens).count
Write-Output "Storegga Entreprenør: $ENTCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Storegga Betong: $BETCopilot" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion

#Lager en liste over brukere med lisens
Remove-Item -Path "C:\temp\Storegga - Brukere med lisens.txt" -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisensene til Storegga pr $Today " | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
"" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding ASCII

#Liste over ledige lisenser
Write-Output "OVERSIKT OVER UBRUKTE LISENSER" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "******************************" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
write-output "Exchange Online Plan 1 = Det finnes i dag $EXO1Unassigned utildelte lisenser" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
write-output "Microsoft 365 Business Premium = Det finnes i dag $M365BPUnassigned utildelte lisenser" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
write-output "Microsoft 365 Copilot = Det finnes i dag $M365COPUnassigned utildelte lisenser" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
"" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding ASCII
"" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding ASCII

#Lister opp brukere med Microsoft 365 Business Premium lisens
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 BUSINESS PREMIUM LISENS" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Entreprenør: Brukere med Microsoft 365 Business Premium lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $ENTMS365BPlisens | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Betong: Brukere med Microsoft 365 Business Premium lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $BETMS365BPlisens | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII

#Lister opp brukere med Exchange Online lisens
Write-Output "OVERSIKT OVER BRUKERE MED EXCHANGE ONLINE LISENS" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "************************************************" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Entreprenør: Brukere med Exchange Online lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $ENTEX01lisens | out-file  -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Ekstra lisens for printer@storeggagruppen.no"| out-file  -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Betong: Brukere med Exchange Online lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $BETEX01lisens | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
"" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding ASCII

#Lister opp brukere med Copilot lisens
Write-Output "OVERSIKT OVER BRUKERE MED COPILOT LISENS" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "************************************************" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Entreprenør: Brukere med Copilot lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $ENTCopilotlisens | out-file  -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "Storegga Betong: Brukere med Copilot lisens" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output $BETCopilotlisens | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding UTF8
"" | out-file -append "C:\temp\Storegga - Brukere med lisens.txt" -Encoding ASCII

