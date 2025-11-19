<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet NTC
Script av:      Kim Skog
============================================================================================
#>


#Kobler fra eksisterende Microsoft Graph API
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
#Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId, ConsumedUnits
#Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId

#Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-NTC.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til The Norwegian Travel Company pr $Today" | out-file -append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#region Setter variabler for software ObjectID for de forskjellige lisenstypene
# SKU ID til produktene
# Power BI Pro
$POWER_BI_PRO = "f8a1db68-be16-40ed-86d5-cb42ce701560"
# PBI_PREMIUM_PER_USER
$PowerBIPremium = "c1d032e0-5619-4761-9b5c-75b6831e1711"
# Microsoft 365 Business Premium
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"
# O365_BUSINESS_ESSENTIALS (Business Basic)
$M365BB = "3b555118-da6a-4418-894f-7df1e2096870"
# EXCHANGESTANDARD
$ExchangeOnlinePlan1 = "4b9405b0-7788-4568-add1-99614e613b69"
# EXCHANGEENTERPRISE
$ExchangeOnlinePlan2 = "19ec0d23-8335-4cbd-94ac-6050e30712fa"
# EXCHANGEDESKLESS
$ExchangeOnlineKiosk = "80b2d799-d2ba-4d2a-8842-fb0d0f3a4b82"
# O365_BUSINESS_PREMIUM (Business Standard)
$M365BS = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"
# Powerapps Premium
$POWERAPPS_PER_USER = "b30411f5-fea1-4a59-9ad9-3db7c7ead579"
# Power Automate Premium
$POWERAUTOMATE_ATTENDED_RPA = "eda1941c-3c4f-4995-b5eb-e85a42175ab9"
# Microsoft_365_F1_EEA_(no_Teams)
$F1 = "0666269f-b167-4c5b-a76f-fc574f2b1118"
# FLOW_PER_USER
$PowerAutomatePerUser = "4a51bf65-409c-4a91-b845-1121b571cc9d"
# Visio Plan 2
$VISIOCLIENT = "c5928f49-12ba-48f7-ada3-0d743a3601d5"
# Microsoft 365 Copilot
$Microsoft_365_Copilot = "639dec6b-bb19-468b-871c-c5c441c4b0cb"
# Office 365 Extra File Storage
$SHAREPOINTSTORAGE = "99049c9c-6011-4908-bf17-15f496e6519d"
# Microsoft Teams Rooms Pro
$Microsoft_Teams_Rooms_Pro = "4cde982a-ede4-4409-9ae6-b003453c8ea6"
#endregion Setter variabler for software ObjectID for de forskjellige lisenstypene

#region Lister opp totalt antall lisenser pr subscription
#Exchange Online Plan 1
$EXO1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO1Unassigned = $EXO1Licensecount+$EXO1Unassignedcount
#Exchange Online Plan 2
$EXO2Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGEENTERPRISE" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGEENTERPRISE"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO2Unassigned = $EXO2Licensecount+$EXO2Unassignedcount
#Exchange Online Kiosk
$EXOKLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGEDESKLESS" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXOKUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGEDESKLESS"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXOKUnassigned = $EXOKLicensecount+$EXOKUnassignedcount
#M365 Business Basic
$M365BBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "O365_BUSINESS_ESSENTIALS" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365BBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "O365_BUSINESS_ESSENTIALS"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365BBUnassigned = $M365BBLicensecount+$M365BBUnassignedcount
#M365 Business Premium
$M365BPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365BPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365BPUnassigned = $M365BPLicensecount+$M365BPUnassignedcount
#Microsoft 365 Business Standard
$M365BSLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "O365_BUSINESS_PREMIUM" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365BSUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "O365_BUSINESS_PREMIUM"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365BSUnassigned = $M365BSLicensecount+$M365BSUnassignedcount
#Microsoft_365_F1_EEA_(no_Teams)
$F1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_F1_EEA_(no_Teams)" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$F1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_F1_EEA_(no_Teams)"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$F1Unassigned = $F1Licensecount+$F1Unassignedcount
#Microsoft 365 Copilot
$M365COPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365COPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365COPUnassigned = $M365COPLicensecount+$M365COPUnassignedcount
#Power Automate per user plan
$PowerAPUPLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "FLOW_PER_USER" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PowerAPUPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "FLOW_PER_USER"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PowerAPUPUnassigned = $PowerAPUPLicensecount+$PowerAPUPUnassignedcount
#PowerBI Pro
$PowerBIProLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "POWER_BI_PRO" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PowerBIProUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "POWER_BI_PRO"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PowerBIProUnassigned = $PowerBIProLicensecount+$PowerBIProUnassignedcount
#PowerBI Premium
$PowerBIPremiumLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "PBI_PREMIUM_PER_USER" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PowerBIPremiumUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "PBI_PREMIUM_PER_USER"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$PowerBIPremiumUnassigned = $PowerBIPremiumLicensecount+$PowerBIPremiumUnassignedcount
#Office365 Extra File Storage
$SHAREPOINTSTORAGE = "99049c9c-6011-4908-bf17-15f496e6519d"
$SharepointLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SHAREPOINTSTORAGE" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
# Microsoft Teams Rooms Pro - totalsummer
$TRProLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq $TeamsRoomsProPartNumber } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$TRProUnassignedcount = Get-MgSubscribedSku | Where-Object { $_.SkuPartnumber -eq $TeamsRoomsProPartNumber } | Select-Object -Property ActiveUnits, ConsumedUnits, SkuPartNumber,@{L='SpareLicenses';E={$_.ActiveUnits - $_.ConsumedUnits}} | Select SkuPartNumber, SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$TRProUnassigned = $TRProLicensecount + $TRProUnassignedcount
#endregion Lister opp totalt antall lisenser pr subscription


#region Lister opp totalt antall lisenser på kunde

write-output "Microsoft 365 Business Premium = Kunde har totalt $M365BPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $M365BPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Microsoft 365 Business Standard = Kunde har totalt $M365BSLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Business Standard = Kunde har $M365BSUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Microsoft 365 Business Basic = Kunde har totalt $M365BBLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Business Basic = Kunde har $M365BBUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "PowerBI Pro = Kunde har totalt $PowerBIProLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "PowerBI Pro = Kunde har $PowerBIProUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "PowerBI Premium = Kunde har totalt $PowerBIPremiumLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "PowerBI Premium = Kunde har $PowerBIPremiumUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Exchange Online Plan 1 = Kunde har totalt $EXO1Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXO1Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Exchange Online Plan 2 = Kunde har totalt $EXO2Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 2 = Kunde har $EXO2Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Exchange Online Kiosk = Kunde har totalt $EXOKLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Kiosk = Kunde har $EXOKUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Power Automate Per user Plan = Kunde har totalt $PowerAPUPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Power Automate Per user Plan = Kunde har $PowerAPUPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Microsoft 365 F1 = Kunde har totalt $F1Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 F1 = Kunde har $F1Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Microsoft 365 Copilot = Kunde har totalt $M365COPLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Copilot = Kunde har $M365COPUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Office365 Extra File Storage (Utvidelse Sharepointlagring) = Kunde har totalt $SharepointLicensecount GB med ekstra Sharepointlagring" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

"" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

write-output "Microsoft Teams Rooms Pro = Kunde har totalt $TRProLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft Teams Rooms Pro = Kunde har $TRProUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Lister opp totalt antall lisenser på kunde

#region Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCM365BP = @($NTCM365BPlisens).count
#Romsdalen
$RomsdalenM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenM365BP = @($RomsdalenM365BPlisens).count
#Fjellheisen
$FjellheisenM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenM365BP = @($FjellheisenM365BPlisens).count
#Snow Hotel Kirkenes
$SnowHotelM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelM365BP = @($SnowHotelM365BPlisens).count
#Arctic Train
$ArcticTrainM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainM365BP = @($ArcticTrainM365BPlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyM365BP = @($SommarøyM365BPlisens).count

Write-Output "NTC: $NTCM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainM365BP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyM365BP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft 365 Business Premium

#region Microsoft 365 Business Standard
Write-Output "Microsoft 365 Business Standard" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCM365BS = @($NTCM365BSlisens).count
#Romsdalen
$RomsdalenM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenM365BS = @($RomsdalenM365BSlisens).count
#Fjellheisen
$FjellheisenM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenM365BS = @($FjellheisenM365BSlisens).count
#Snow Hotel Kirkenes
$SnowHotelM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelM365BS = @($SnowHotelM365BSlisens).count
#Arctic Train
$ArcticTrainM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainM365BS = @($ArcticTrainM365BSlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyM365BSlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BS -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyM365BS = @($SommarøyM365BSlisens).count


Write-Output "NTC: $NTCM365BS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenM365BS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenM365BS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelM365BS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainM365BS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyM365BS" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft 365 Business Standard

#region Microsoft 365 Business Basic
Write-Output "Microsoft 365 Business Basic" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCM365BB = @($NTCM365BBlisens).count
#Romsdalen
$RomsdalenM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenM365BB = @($RomsdalenM365BBlisens).count
#Fjellheisen
$FjellheisenM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenM365BB = @($FjellheisenM365BBlisens).count
#Snow Hotel Kirkenes
$SnowHotelM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelM365BB = @($SnowHotelM365BBlisens).count
#Arctic Train
$ArcticTrainM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainM365BB = @($ArcticTrainM365BBlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyM365BBlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $M365BB -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyM365BB = @($ArcticTrainM365BBlisens).count

Write-Output "NTC: $NTCM365BB" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenM365BB" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenM365BB" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelM365BB" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainM365BB" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyM365BB" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft 365 Business Basic

#region Microsoft 365 Copilot
Write-Output "Microsoft 365 Copilot" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCCOP = @($NTCCOPlisens).count
#Romsdalen
$RomsdalenCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenCOP = @($RomsdalenCOPlisens).count
#Fjellheisen
$FjellheisenCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenCOP = @($FjellheisenCOPlisens).count
#Snow Hotel Kirkenes
$SnowHotelCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelCOP = @($SnowHotelCOPlisens).count
#Arctic Train
$ArcticTrainCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainCOP = @($ArcticTrainCOPlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyCOP = @($SommarøyCOPlisens).count


Write-Output "NTC: $NTCCOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenCOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenCOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelCOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainCOP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyCOP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft 365 Copilot

#region Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCEXO1 = @($NTCEXO1lisens).count
#Romsdalen
$RomsdalenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenEXO1 = @($RomsdalenEXO1lisens).count
#Fjellheisen
$FjellheisenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenEXO1 = @($FjellheisenEXO1lisens).count
#Snow Hotel Kirkenes
$SnowHotelEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelEXO1 = @($SnowHotelEXO1lisens).count
#Arctic Train
$ArcticTrainEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainEXO1 = @($ArcticTrainEXO1lisens).count
#Sommarøy Arctic Hotel AS
$SommarøyEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1 -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyEXO1 = @($SommarøyEXO1lisens).count


Write-Output "NTC: $NTCEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyEXO1" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Exchange Online Plan 1

#region Exchange Online Plan 2
Write-Output "Exchange Online Plan 2" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCEXOP2 = @($NTCEXOP2lisens).count
#Romsdalen
$RomsdalenEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenEXOP2 = @($RomsdalenEXOP2lisens).count
#Fjellheisen
$FjellheisenEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenEXOP2 = @($FjellheisenEXOP2lisens).count
#Snow Hotel Kirkenes
$SnowHotelEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelEXOP2 = @($SnowHotelEXOP2isens).count-1
#Arctic Train
$ArcticTrainEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainEXOP2 = @($ArcticTrainEXOP2lisens).count
#Sommarøy Arctic Hotel AS
$SommarøyEXOP2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyEXOP2 = @($SommarøyEXOP2lisens).count


Write-Output "NTC: $NTCEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainEXOP2" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyEXOP2" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Exchange Online Plan 2

#region Exchange Online Kiosk
Write-Output "Exchange Online Kiosk" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCEXOK = @($NTCEXOKlisens).count
#Romsdalen
$RomsdalenEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenEXOK = @($RomsdalenEXOKlisens).count
#Fjellheisen
$FjellheisenEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenEXOK = @($FjellheisenEXOKlisens).count
#Snow Hotel Kirkenes
$SnowHotelEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelEXOK = @($SnowHotelEXOKisens).count
#Arctic Train
$ArcticTrainEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainEXOK = @($ArcticTrainEXOKlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyEXOKlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyEXOK = @($SommarøyEXOKlisens).count


Write-Output "NTC: $NTCEXOK" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenEXOK" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenEXOK" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelEXOK" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainEXOK" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyEXOK" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Exchange Online Kiosk

#region PowerBI Pro
Write-Output "PowerBI Pro" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCPBIP = @($NTCPBIPlisens).count
#Romsdalen
$RomsdalenPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenPBIP = @($RomsdalenPBIPlisens).count
#Fjellheisen
$FjellheisenPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenPBIP = @($FjellheisenPBIPlisens).count
#Snow Hotel Kirkenes
$SnowHotelPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelPBIP = @($SnowHotelPBIPisens).count-1
#Arctic Train
$ArcticTrainPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainPBIP = @($ArcticTrainPBIPlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyPBIPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $POWER_BI_PRO -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyPBIP = @($SommarøyPBIPlisens).count


Write-Output "NTC: $NTCPBIP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenPBIP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenPBIP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelPBIP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainPBIP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyPBIP" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion PowerBI Pro

#region PowerBI Premium
Write-Output "PowerBI Premium" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCPBIPU = @($NTCPBIPUlisens).count
#Romsdalen
$RomsdalenPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenPBIPU = @($RomsdalenPBIPUlisens).count
#Fjellheisen
$FjellheisenPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenPBIPU = @($FjellheisenPBIPUlisens).count
#Snow Hotel Kirkenes
$SnowHotelPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelPBIPU = @($SnowHotelPBIPUlisens).count
#Arctic Train
$ArcticTrainPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainPBIPU = @($ArcticTrainPBIPUlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyPBIPUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerBIPremium -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyPBIPU = @($SommarøyPBIPUlisens).count


Write-Output "NTC: $NTCPBIPU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenPBIPU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenPBIPU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelPBIPU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainPBIUP" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyPBIPU" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion PowerBI Premium

#region Power Automate Users
Write-Output "Power Automate Users" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCPAU = @($NTCPAUlisens).count
#Romsdalen
$RomsdalenPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenPAU = @($RomsdalenPAUlisens).count
#Fjellheisen
$FjellheisenPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenPAU = @($FjellheisenPAUlisens).count
#Snow Hotel Kirkenes
$SnowHotelPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelPAU = @($SnowHotelPAUlisens).count
#Arctic Train
$ArcticTrainPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainPAU = @($ArcticTrainPAUlisens).count
#Sommarøy Arctic Hotel AS
$SommarøyPAUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyPAU = @($SommarøyPAUlisens).count

Write-Output "NTC: $NTCPAU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenPAU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenPAU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelPAU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainPAU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyPAU" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Power Automate Users

#region Microsoft 365 F1
Write-Output "Microsoft 365 F1" | out-file -append "$FilePath" -Encoding UTF8
#NTC
$NTCF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and $_.Department -like "NTC"} | Select-Object DisplayName, UserPrincipalName
$NTCF1 = @($NTCF1lisens).count
#Romsdalen
$RomsdalenF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and $_.Department -like "Romsdalen"} | Select-Object DisplayName, UserPrincipalName
$RomsdalenF1 = @($RomsdalenF1lisens).count
#Fjellheisen
$FjellheisenF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and $_.Department -like "Fjellheisen AS"} | Select-Object DisplayName, UserPrincipalName
$FjellheisenF1 = @($FjellheisenF1lisens).count
#Snow Hotel Kirkenes
$SnowHotelF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,CompanyName" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and ($_.CompanyName -like "Snowhotel Kirkenes" -or $_.CompanyName -like "Snow Resort Kirkenes")} | Select-Object DisplayName, UserPrincipalName
$SnowHotelF1 = @($SnowHotelF1lisens).count
#Arctic Train
$ArcticTrainF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and $_.Department -like "Arctic Train AS"} | Select-Object DisplayName, UserPrincipalName
$ArcticTrainF1 = @($ArcticTrainF1lisens).count
#Sommarøy Arctic Hotel AS
$SommarøyF1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $F1 -and $_.Department -like "Sommarøy Arctic Hotel AS"} | Select-Object DisplayName, UserPrincipalName
$SommarøyF1 = @($SommarøyF1lisens).count

Write-Output "NTC: $NTCF1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenF1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Fjellheisen: $FjellheisenF1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Snow Hotel Kirkenes: $SnowHotelF1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Arctic Train: $ArcticTrainF1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Sommarøy Arctic Hotel AS: $SommarøyF1" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft 365 F1

#region #region Microsoft Teams Rooms Pro
Write-Output "Microsoft Teams Rooms Pro" | out-file -append "$FilePath" -Encoding UTF8

$NTCTRProLisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object { $_.AssignedLicenses.SkuId -contains $TeamsRoomsPro -and $_.Department -like "NTC" } | Select-Object DisplayName, UserPrincipalName
$NTCTRPro = @($NTCTRProLisens).count

$RomsdalenTRProLisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" |
  Where-Object { $_.AssignedLicenses.SkuId -contains $TeamsRoomsPro -and $_.Department -like "Romsdalen" } |
  Select-Object DisplayName, UserPrincipalName
$RomsdalenTRPro = @($RomsdalenTRProLisens).count

# ... gjenta for Fjellheisen AS, Snowhotel Kirkenes/Snow Resort Kirkenes (CompanyName), Arctic Train AS, Sommarøy Arctic Hotel AS

Write-Output "NTC: $NTCTRPro" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Romsdalen: $RomsdalenTRPro" | out-file -append "$FilePath" -Encoding UTF8
# ... resten
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion Microsoft Teams Rooms Pro


#Lisensierte brukere
$MS365BSUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $M365BS} | Select-Object DisplayName, UserPrincipalName
$MS365BBUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $M365BB} | Select-Object DisplayName, UserPrincipalName
$MS365BPUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $SPB} | Select-Object DisplayName, UserPrincipalName
$EX01Users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan1} | Select-Object DisplayName, UserPrincipalName
$EX02Users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2} | Select-Object DisplayName, UserPrincipalName
$EX0KioskUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $ExchangeOnlineKiosk} | Select-Object DisplayName, UserPrincipalName
$PBIProUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $POWER_BI_PRO} | Select-Object DisplayName, UserPrincipalName
$PBIPremiumUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $PowerBIPremium} | Select-Object DisplayName, UserPrincipalName
$PowerAutomateUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $PowerAutomatePerUser} | Select-Object DisplayName, UserPrincipalName
$CopilotUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot} | Select-Object DisplayName, UserPrincipalName
$F1Users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $F1} | Select-Object DisplayName, UserPrincipalName


#Lister opp brukere med Microsoft 365 Business Standard Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 BUSINESS STANDARD LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $MS365BSUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Microsoft 365 Business Basic Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 BUSINESS BASIC LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $MS365BBUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Microsoft 365 Business Premium Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 BUSINESS PREMIUM LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $MS365BPUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Exhange Online PLan 1 Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED EXCHANGE ONLINE PLAN 1 LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $EX01Users | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Exchange Online Plan 2 Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED EXCHANGE ONLINE PLAN 2 LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $EX02Users | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Exchange Online Kiosk Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED EXCHANGE ONLINE KIOSK LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $EX0KioskUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Power BI Pro Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED POWER BI PRO LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $PBIProUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Power BI Premium Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED POWER BI PREMIUM LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $PBIPremiumUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Power Automate Per User Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED POWER AUTOMATE PER USER LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $PowerAutomateUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Microsoft 365 Copilot Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 COPILOT LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $CopilotUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Microsoft 365 F1 Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 F1 LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $F1Users | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

# Lister opp brukere med Microsoft Teams Rooms Pro lisens
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT TEAMS ROOMS PRO LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8

$TeamsRoomsProUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" |
  Where-Object { $_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $TeamsRoomsPro } |
  Select-Object DisplayName, UserPrincipalName

Write-Output $TeamsRoomsProUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8