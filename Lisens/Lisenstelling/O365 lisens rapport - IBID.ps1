<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet IBID tenanten
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
$FilePath = "C:\temp\O365Users-IBID.txt"

<#
Domener i IBID tenanten
*ibidsa.onmicrosoft.com (Standard)
*barnehagenhundre.no
*domkirkens.no
*einerabben.no
*ekrehagen.com
ibid-sa.no
*kraakeslottet.no
*kveldrovegen.no
*lioya.no
*norrona-barnehage.no
*polarhagen-barnehage.no
*Soldagenbhg.no
*tusseladden.com
*aabhg.no
*skogstuabarnehage.no
*karveslettlia.no
*hamnafriluftsbarnehage.no
*trollskogenbarn.no
*kanuttenbh.no
*ameliahaugen.no
*bjerkakerbarnehage.no
*kulturbarnehagen.tromso.no
#>

Remove-Item -Path "$FilePath" -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til IBID AS pr $Today" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#region Setter variabler for software ObjectID for de forskjellige lisenstypene
$INTUNE_EDU = "d9d89b70-a645-4c24-b041-8d3cb1884ec7"
#O365 A3
$ENTERPRISEPACKPLUS_FACULTY = "e578b273-6db4-4691-bba0-8d691f4da603"
#Exchange Online Plan 1
$EXCHANGESTANDARD = "4b9405b0-7788-4568-add1-99614e613b69"
#M365 A3
$M365EDU_A3_FACULTY = "4b590615-0888-425a-a965-b3bf7789848d"
$STANDARDWOFFPACK_FACULTY = "94763226-9b3c-4e75-a931-5c89701abe66"
#Microsoft 365 Copilot
$Microsoft_365_Copilot = "639dec6b-bb19-468b-871c-c5c441c4b0cb"
$Microsoft_365_Copilot_EDU = "ad9c22b3-52d7-4e7e-973c-88121ea96436"
#endregion

#region Lister opp totalt antall lisenser pr subscription
#Microsoft Intune for Education
$INTUNE_EDULicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "INTUNE_EDU" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$INTUNE_EDUUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "INTUNE_EDU"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$INTUNE_EDUUnassigned = $INTUNE_EDULicensecount+$INTUNE_EDUUnassignedcount
#Office 365 A3 for lærere
$O365A3Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "ENTERPRISEPACKPLUS_FACULTY" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$O365A3Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "ENTERPRISEPACKPLUS_FACULTY"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$O365A3Unassigned = $O365A3Licensecount+$O365A3Unassignedcount
#Exchange Online Plan 1
$EXO1Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGESTANDARD" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO1Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGESTANDARD"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO1Unassigned = $EXO1Licensecount+$EXO1Unassignedcount
#Microsoft 365 A3 for lærere
$M365A3Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "M365EDU_A3_FACULTY" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365A3Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "M365EDU_A3_FACULTY"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365A3Unassigned = $M365A3Licensecount+$M365A3Unassignedcount
#Microsoft 365 Copilot
$M365CopilotLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365CopiloEDUtLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot_EDU" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365CopilotUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365CopilotEDUUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot_EDU"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | select SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365Copilottotal = $M365CopilotLicensecount+$M365CopiloEDUtLicensecount
$M365CopilotUnassignedtotal = $M365CopilotUnassignedcount+$M365CopilotEDUUnassignedcount
$M365CopilotUnassigned = $M365Copilottotal+$M365CopilotUnassignedtotal

#Lister opp totalt antall lisenser på kunde
write-output "Microsoft Intune for Education = Kunde har totalt $INTUNE_EDULicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft Intune for Education = Kunde har $INTUNE_EDUUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Office 365 A3 for lærere = Kunde har totalt $O365A3Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Office 365 A3 for lærere = Kunde har $O365A3Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Exchange Online Plan 1 = Kunde har totalt $EXO1Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Exchange Online Plan 1 = Kunde har $EXO1Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Microsoft 365 A3 for lærere = Kunde har totalt $M365A3Licensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 A3 for lærere = Kunde har $M365A3Unassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Microsoft 365 Copilot = Kunde har totalt $M365CopilotLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Copilot = Kunde har $M365CopilotUnassigned utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
write-output "Microsoft 365 Copilot for Microsoft 365 A3 and A5 (Education Faculty Pricing) = Kunde har totalt $M365CopiloEDUtLicensecount lisenser" | out-file -append "$FilePath" -Encoding UTF8
write-output "Microsoft 365 Copilot for Microsoft 365 A3 and A5 (Education Faculty Pricing) = Kunde har $M365CopilotEDUUnassignedcount utildelte lisenser" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII
#endregion

#Region Opptelling av antall lisenser pr firma
#Microsoft Intune for Education
Write-Output "Microsoft Intune for Education" | out-file -append "$FilePath" -Encoding UTF8
#IBID
$IBIDIntunelisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $INTUNE_EDU }) -and ($_.UserPrincipalName -like "*ibidsa.onmicrosoft.com") } | Select-Object DisplayName, UserPrincipalName
$IBIDIntune = @($IBIDIntunelisens).count
Write-Output "IBID: $IBIDIntune" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Microsoft 365 A3 for lærere
Write-Output "Microsoft 365 A3 for lærere" | out-file -append "$FilePath" -Encoding UTF8
#IBID
$IBIDM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*ibid-sa.no") } | Select-Object DisplayName, UserPrincipalName
$IBIDM365A3 = @($IBIDM365A3lisens).count
#Liøya
$LioyaM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*lioya.no") } | Select-Object DisplayName, UserPrincipalName
$LioyaM365A3 = @($LioyaM365A3lisens).count
#Barnehagen 100
$B100M365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*barnehagenhundre.no") } | Select-Object DisplayName, UserPrincipalName
$B100M365A3 = @($B100M365A3lisens).count
#Domkirkenes Barnehage
$DomkirkenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*domkirkens.no") } | Select-Object DisplayName, UserPrincipalName
$DomkirkenM365A3 = @($DomkirkenM365A3lisens).count
#Einerabben Barnehage
#$EinerabbenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*einerabben.no") } | Select-Object DisplayName, UserPrincipalName
#$EinerabbenM365A3 = @($EinerabbenM365A3lisens).count
#Ekrehagen Barnehage
$EkrehagenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*ekrehagen.com") } | Select-Object DisplayName, UserPrincipalName
$EkrehagenM365A3 = @($EkrehagenM365A3lisens).count
#Kråkeslottet Barnehage
$KrakeslottetM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*kraakeslottet.no") } | Select-Object DisplayName, UserPrincipalName
$KrakeslottetM365A3 = @($KrakeslottetM365A3lisens).count
#Kveldrovegen Barnehage
$KveldrovegenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*kveldrovegen.no") } | Select-Object DisplayName, UserPrincipalName
$KveldrovegenM365A3 = @($KveldrovegenM365A3lisens).count
#Norrønna Barnehage
$NorronnaM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*norrona-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$NorronnaM365A3 = @($NorronnaM365A3lisens).count
#Polarhagen Barnehage
$PolarhagenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*polarhagen-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$PolarhagenM365A3 = @($PolarhagenM365A3lisens).count
#Soldagen Barnehage
$SoldagenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*Soldagenbhg.no") } | Select-Object DisplayName, UserPrincipalName
$SoldagenM365A3 = @($SoldagenM365A3lisens).count
#Hamna Friluftsbarnehage
$HamnaM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*hamnafriluftsbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$HamnaM365A3 = @($HamnaM365A3lisens).count
#Tusseladden Barnehage
$TusseladdenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*tusseladden.com") } | Select-Object DisplayName, UserPrincipalName
$TusseladdenM365A3 = @($TusseladdenM365A3lisens).count
#Åsland Barnehage
$AslandM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*aabhg.no") } | Select-Object DisplayName, UserPrincipalName
$AslandM365A3 = @($AslandM365A3lisens).count
#Skogstua Barnehage
$SkogstuaM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*skogstuabarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$SkogstuaM365A3 = @($SkogstuaM365A3lisens).count
#Karveslettlia Barnehage
$KarveslettliaM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*karveslettlia.no") } | Select-Object DisplayName, UserPrincipalName
$KarveslettliaM365A3 = @($KarveslettliaM365A3lisens).count
#Trollskogen Barnehage
$TrollskogenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*trollskogenbarn.no") } | Select-Object DisplayName, UserPrincipalName
$TrollskogenM365A3 = @($TrollskogenM365A3lisens).count
#Kanutten Barnehage
$KanuttenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*kanuttenbh.no") } | Select-Object DisplayName, UserPrincipalName
$KanuttenM365A3 = @($KanuttenM365A3lisens).count
#Ameliahaugen Barnehage
$AmeliahaugenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*ameliahaugen.no") } | Select-Object DisplayName, UserPrincipalName
$AmeliahaugenM365A3 = @($AmeliahaugenM365A3lisens).count
#Bjerkaker Barnehage
$BjerkakerM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$BjerkakerM365A3 = @($BjerkakerM365A3lisens).count
#Kulturbarnehagen
$KulturbarnehagenM365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $M365EDU_A3_FACULTY }) -and ($_.UserPrincipalName -like "*kulturbarnehagen.tromso.no") } | Select-Object DisplayName, UserPrincipalName
$KulturbarnehagenM365A3 = @($KulturbarnehagenM365A3lisens).count

Write-Output "IBID: $IBIDM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Liøya Barnehage: $LioyaM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Barnehagen Hundre: $B100M365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Domkirkens Barnehage: $DomkirkenM365A3" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Einerabben Barnehage: $EinerabbenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ekrehagen Barnehage: $EkrehagenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kråkeslottet Barnehage: $KrakeslottetM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kveldrovegen Barnehage: $KveldrovegenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Norrønna Barnehage: $NorronnaM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Polarhagen Barnehage: $PolarhagenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Soldagen Barnehage: $SoldagenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Tusseladden Barnehage: $TusseladdenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Åsland Barnehage: $AslandM365A3" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Skogstua Barnehage: $SkogstuaM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Karveslettlia Barnehage: $KarveslettliaM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Hamna Friluftsbarnehage: $HamnaM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Trollskogen Barnehage: $TrollskogenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kanutten Barnehage: $KanuttenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ameliahaugen Barnehage: $AmeliahaugenM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Bjerkaker Barnehage: $BjerkakerM365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kulturbarnehagen: $KulturbarnehagenM365A3" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Office 365 A3 for lærere
Write-Output "Office 365 A3 for lærere" | out-file -append "$FilePath" -Encoding UTF8
#IBID
#inkluderer seritadmin
$IBIDO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*ibid-sa.no") } | Select-Object DisplayName, UserPrincipalName
$IBIDO365A3 = @($IBIDO365A3lisens).count+1
#Liøya
$LioyaO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*lioya.no") } | Select-Object DisplayName, UserPrincipalName
$LioyaO365A3 = @($LioyaO365A3lisens).count
#Barnehagen 100
$B100O365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*barnehagenhundre.no") } | Select-Object DisplayName, UserPrincipalName
$B100O365A3 = @($B100O365A3lisens).count
#Domkirkenes Barnehage
$DomkirkenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*domkirkens.no") } | Select-Object DisplayName, UserPrincipalName
$DomkirkenO365A3 = @($DomkirkenO365A3lisens).count
#Einerabben Barnehage
#$EinerabbenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*einerabben.no") } | Select-Object DisplayName, UserPrincipalName
#$EinerabbenO365A3 = @($EinerabbenO365A3lisens).count
#Ekrehagen Barnehage
$EkrehagenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*ekrehagen.com") } | Select-Object DisplayName, UserPrincipalName
$EkrehagenO365A3 = @($EkrehagenO365A3lisens).count
#Kråkeslottet Barnehage
$KrakeslottetO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*kraakeslottet.no") } | Select-Object DisplayName, UserPrincipalName
$KrakeslottetO365A3 = @($KrakeslottetO365A3lisens).count
#Kveldrovegen Barnehage
$KveldrovegenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*kveldrovegen.no") } | Select-Object DisplayName, UserPrincipalName
$KveldrovegenO365A3 = @($KveldrovegenO365A3lisens).count
#Norrønna Barnehage
$NorronnaO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*norrona-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$NorronnaO365A3 = @($NorronnaO365A3lisens).count
#Polarhagen Barnehage
$PolarhagenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*polarhagen-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$PolarhagenO365A3 = @($PolarhagenO365A3lisens).count
#Soldagen Barnehage
$SoldagenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*Soldagenbhg.no") } | Select-Object DisplayName, UserPrincipalName
$SoldagenO365A3 = @($SoldagenO365A3lisens).count
#Hamna Friluftsbarnehage
$HamnaO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*hamnafriluftsbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$HamnaO365A3 = @($HamnaO365A3lisens).count
#Tusseladden Barnehage
$TusseladdenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*tusseladden.com") } | Select-Object DisplayName, UserPrincipalName
$TusseladdenO365A3 = @($TusseladdenO365A3lisens).count
#Åsland Barnehage
$AslandO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*aabhg.no") } | Select-Object DisplayName, UserPrincipalName
$AslandO365A3 = @($AslandO365A3lisens).count
#Skogstua Barnehage
#$SkogstuaO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*skogstuabarnehage.no") } | Select-Object DisplayName, UserPrincipalName
#$SkogstuaO365A3 = @($SkogstuaO365A3lisens).count
#Karveslettlia Barnehage
$KarveslettliaO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*karveslettlia.no") } | Select-Object DisplayName, UserPrincipalName
$KarveslettliaO365A3 = @($KarveslettliaO365A3lisens).count
#Trollskogen Barnehage
$TrollskogenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*trollskogenbarn.no") } | Select-Object DisplayName, UserPrincipalName
$TrollskogenO365A3 = @($TrollskogenO365A3lisens).count
#Kanutten Barnehage
$KanuttenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*kanuttenbh.no") } | Select-Object DisplayName, UserPrincipalName
$KanuttenO365A3 = @($KanuttenO365A3lisens).count
#Ameliahaugen Barnehage
$AmeliahaugenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*ameliahaugen.no") } | Select-Object DisplayName, UserPrincipalName
$AmeliahaugenO365A3 = @($AmeliahaugenO365A3lisens).count
#Bjerkaker Barnehage
$BjerkakerO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$BjerkakerO365A3 = @($BjerkakerO365A3lisens).count
#Kulturbarnehagen
$KulturbarnehagenO365A3lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $ENTERPRISEPACKPLUS_FACULTY }) -and ($_.UserPrincipalName -like "*kulturbarnehagen.tromso.no") } | Select-Object DisplayName, UserPrincipalName
$KulturbarnehagenO365A3 = @($KulturbarnehagenO365A3lisens).count

Write-Output "IBID: $IBIDO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Liøya Barnehage: $LioyaO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Barnehagen Hundre: $B100O365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Domkirkens Barnehage: $DomkirkenO365A3" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Einerabben Barnehage: $EinerabbenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ekrehagen Barnehage: $EkrehagenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kråkeslottet Barnehage: $KrakeslottetO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kveldrovegen Barnehage: $KveldrovegenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Norrønna Barnehage: $NorronnaO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Polarhagen Barnehage: $PolarhagenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Soldagen Barnehage: $SoldagenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Tusseladden Barnehage: $TusseladdenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Åsland Barnehage: $AslandO365A3" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Skogstua Barnehage: $SkogstuaO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Karveslettlia Barnehage: $KarveslettliaO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Hamna Friluftsbarnehage: $HamnaO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Trollskogen Barnehage: $TrollskogenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kanutten Barnehage: $KanuttenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ameliahaugen Barnehage: $AmeliahaugenO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Bjerkaker Barnehage: $BjerkakerO365A3" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kulturbarnehagen: $KulturbarnehagenO365A3" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII


#Exchange Online Plan 1
Write-Output "Exchange Online Plan 1" | out-file -append "$FilePath" -Encoding UTF8
#IBID
$IBIDEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*ibid-sa.no") } | Select-Object DisplayName, UserPrincipalName
$IBIDEXO1 = @($IBIDEXO1lisens).count
#Liøya
$LioyaEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*lioya.no") } | Select-Object DisplayName, UserPrincipalName
$LioyaEXO1 = @($LioyaEXO1lisens).count
#Barnehagen 100
$B100EXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*barnehagenhundre.no") } | Select-Object DisplayName, UserPrincipalName
$B100EXO1 = @($B100EXO1lisens).count
#Domkirkenes Barnehage
$DomkirkenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*domkirkens.no") } | Select-Object DisplayName, UserPrincipalName
$DomkirkenEXO1 = @($DomkirkenEXO1lisens).count
#Einerabben Barnehage
#$EinerabbenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*einerabben.no") } | Select-Object DisplayName, UserPrincipalName
#$EinerabbenEXO1 = @($EinerabbenEXO1lisens).count
#Ekrehagen Barnehage
$EkrehagenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*ekrehagen.com") } | Select-Object DisplayName, UserPrincipalName
$EkrehagenEXO1 = @($EkrehagenEXO1lisens).count
#Kråkeslottet Barnehage
$KrakeslottetEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*kraakeslottet.no") } | Select-Object DisplayName, UserPrincipalName
$KrakeslottetEXO1 = @($KrakeslottetEXO1lisens).count
#Kveldrovegen Barnehage
$KveldrovegenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*kveldrovegen.no") } | Select-Object DisplayName, UserPrincipalName
$KveldrovegenEXO1 = @($KveldrovegenEXO1lisens).count
#Norrønna Barnehage
$NorronnaEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*norrona-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$NorronnaEXO1 = @($NorronnaEXO1lisens).count
#Polarhagen Barnehage
$PolarhagenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*polarhagen-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$PolarhagenEXO1 = @($PolarhagenEXO1lisens).count
#Soldagen Barnehage
$SoldagenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*Soldagenbhg.no") } | Select-Object DisplayName, UserPrincipalName
$SoldagenEXO1 = @($SoldagenEXO1lisens).count
#Hamna Friluftsbarnehage
$HamnaEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*hamnafriluftsbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$HamnaEXO1 = @($HamnaEXO1lisens).count
#Tusseladden Barnehage
$TusseladdenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*tusseladden.com") } | Select-Object DisplayName, UserPrincipalName
$TusseladdenEXO1 = @($TusseladdenEXO1lisens).count
#Åsland Barnehage
$AslandEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*aabhg.no") } | Select-Object DisplayName, UserPrincipalName
$AslandEXO1 = @($AslandEXO1lisens).count
#Skogstua Barnehage
#$SkogstuaEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*skogstuabarnehage.no") } | Select-Object DisplayName, UserPrincipalName
#$SkogstuaEXO1 = @($SkogstuaEXO1lisens).count
#Karveslettlia Barnehage
$KarveslettliaEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*karveslettlia.no") } | Select-Object DisplayName, UserPrincipalName
$KarveslettliaEXO1 = @($KarveslettliaEXO1lisens).count
#Trollskogen Barnehage
$TrollskogenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*trollskogenbarn.no") } | Select-Object DisplayName, UserPrincipalName
$TrollskogenEXO1 = @($TrollskogenEXO1lisens).count
#Kanutten Barnehage
$KanuttenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*kanuttenbh.no") } | Select-Object DisplayName, UserPrincipalName
$KanuttenEXO1 = @($KanuttenEXO1lisens).count
#Ameliahaugen Barnehage
$AmeliahaugenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*ameliahaugen.no") } | Select-Object DisplayName, UserPrincipalName
$AmeliahaugenEXO1 = @($AmeliahaugenEXO1lisens).count
#Bjerkaker Barnehage
$BjerkakerEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$BjerkakerEXO1 = @($BjerkakerEXO1lisens).count
#Kulturbarnehagen
$KulturbarnehagenEXO1lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $EXCHANGESTANDARD }) -and ($_.UserPrincipalName -like "*kulturbarnehagen.tromso.no") } | Select-Object DisplayName, UserPrincipalName
$KulturbarnehagenEXO1 = @($KulturbarnehagenEXO1lisens).count

Write-Output "IBID: $IBIDEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Liøya Barnehage: $LioyaEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Barnehagen Hundre: $B100EXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Domkirkens Barnehage: $DomkirkenEXO1" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Einerabben Barnehage: $EinerabbenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ekrehagen Barnehage: $EkrehagenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kråkeslottet Barnehage: $KrakeslottetEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kveldrovegen Barnehage: $KveldrovegenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Norrønna Barnehage: $NorronnaEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Polarhagen Barnehage: $PolarhagenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Soldagen Barnehage: $SoldagenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Tusseladden Barnehage: $TusseladdenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Åsland Barnehage: $AslandEXO1" | out-file -append "$FilePath" -Encoding UTF8
#Write-Output "Skogstua Barnehage: $SkogstuaEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Karveslettlia Barnehage: $KarveslettliaEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Hamna Friluftsbarnehage: $HamnaEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Trollskogen Barnehage: $TrollskogenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kanutten Barnehage: $KanuttenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ameliahaugen Barnehage: $AmeliahaugenEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Bjerkaker Barnehage: $BjerkakerEXO1" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kulturbarnehagen: $KulturbarnehagenEXO1" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Microsoft 365 Copilot
Write-Output "Microsoft 365 Copilot" | out-file -append "$FilePath" -Encoding UTF8
#IBID
$IBIDCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*ibid-sa.no") } | Select-Object DisplayName, UserPrincipalName
$IBIDCopilot = @($IBIDCopilotlisens).count
#Liøya
$LioyaCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*lioya.no") } | Select-Object DisplayName, UserPrincipalName
$LioyaCopilot = @($LioyaCopilotlisens).count
#Barnehagen 100
$B100Copilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*barnehagenhundre.no") } | Select-Object DisplayName, UserPrincipalName
$B100Copilot = @($B100Copilotlisens).count
#Domkirkenes Barnehage
$DomkirkenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*domkirkens.no") } | Select-Object DisplayName, UserPrincipalName
$DomkirkenCopilot = @($DomkirkenCopilotlisens).count
#Einerabben Barnehage
$EinerabbenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*einerabben.no") } | Select-Object DisplayName, UserPrincipalName
$EinerabbenCopilot = @($EinerabbenCopilotlisens).count
#Ekrehagen Barnehage
$EkrehagenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*ekrehagen.com") } | Select-Object DisplayName, UserPrincipalName
$EkrehagenCopilot = @($EkrehagenCopilotlisens).count
#Kråkeslottet Barnehage
$KrakeslottetCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*kraakeslottet.no") } | Select-Object DisplayName, UserPrincipalName
$KrakeslottetCopilot = @($KrakeslottetCopilotlisens).count
#Kveldrovegen Barnehage
$KveldrovegenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*kveldrovegen.no") } | Select-Object DisplayName, UserPrincipalName
$KveldrovegenCopilot = @($KveldrovegenCopilotlisens).count
#Norrønna Barnehage
$NorronnaCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*norrona-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$NorronnaCopilot = @($NorronnaCopilotlisens).count
#Polarhagen Barnehage
$PolarhagenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*polarhagen-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$PolarhagenCopilot = @($PolarhagenCopilotlisens).count
#Soldagen Barnehage
$SoldagenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*Soldagenbhg.no") } | Select-Object DisplayName, UserPrincipalName
$SoldagenCopilot = @($SoldagenCopilotlisens).count
#Hamna Friluftsbarnehage
$HamnaCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*hamnafriluftsbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$HamnaCopilot = @($HamnaCopilotlisens).count
#Tusseladden Barnehage
$TusseladdenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*tusseladden.com") } | Select-Object DisplayName, UserPrincipalName
$TusseladdenCopilot = @($TusseladdenCopilotlisens).count
#Åsland Barnehage
$AslandCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*aabhg.no") } | Select-Object DisplayName, UserPrincipalName
$AslandCopilot = @($AslandCopilotlisens).count
#Skogstua Barnehage
$SkogstuaCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*skogstuabarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$SkogstuaCopilot = @($SkogstuaCopilotlisens).count
#Karveslettlia Barnehage
$KarveslettliaCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*karveslettlia.no") } | Select-Object DisplayName, UserPrincipalName
$KarveslettliaCopilot = @($KarveslettliaCopilotlisens).count
#Trollskogen Barnehage
$TrollskogenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*trollskogenbarn.no") } | Select-Object DisplayName, UserPrincipalName
$TrollskogenCopilot = @($TrollskogenCopilotlisens).count
#Kanutten Barnehage
$KanuttenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*kanuttenbh.no") } | Select-Object DisplayName, UserPrincipalName
$KanuttenCopilot = @($KanuttenCopilotlisens).count
#Ameliahaugen Barnehage
$AmeliahaugenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*ameliahaugen.no") } | Select-Object DisplayName, UserPrincipalName
$AmeliahaugenCopilot = @($AmeliahaugenCopilotlisens).count
#Bjerkaker Barnehage
$BjerkakerCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$BjerkakerCopilot = @($BjerkakerCopilotlisens).count
#Kulturbarnehagen
$KulturbarnehagenCopilotlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$KulturbarnehagenCopilot = @($KulturbarnehagenCopilotlisens).count

Write-Output "IBID: $IBIDCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Liøya Barnehage: $LioyaCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Barnehagen Hundre: $B100Copilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Domkirkens Barnehage: $DomkirkenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Einerabben Barnehage: $EinerabbenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ekrehagen Barnehage: $EkrehagenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kråkeslottet Barnehage: $KrakeslottetCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kveldrovegen Barnehage: $KveldrovegenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Norrønna Barnehage: $NorronnaCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Polarhagen Barnehage: $PolarhagenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Soldagen Barnehage: $SoldagenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Tusseladden Barnehage: $TusseladdenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Åsland Barnehage: $AslandCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Skogstua Barnehage: $SkogstuaCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Karveslettlia Barnehage: $KarveslettliaCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Hamna Friluftsbarnehage: $HamnaCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Trollskogen Barnehage: $TrollskogenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kanutten Barnehage: $KanuttenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ameliahaugen Barnehage: $AmeliahaugenCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Bjerkaker Barnehage: $BjerkakerCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kulturbarnehagen: $BjerkakerCopilot" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

#Microsoft 365 Copilot Education
Write-Output "Microsoft 365 Copilot for Microsoft 365 A3 and A5 (Education Faculty Pricing)" | out-file -append "$FilePath" -Encoding UTF8
#IBID
$IBIDCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*ibid-sa.no") } | Select-Object DisplayName, UserPrincipalName
$IBIDCopilotEDU = @($IBIDCopilotEDUlisens).count
#Liøya
$LioyaCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*lioya.no") } | Select-Object DisplayName, UserPrincipalName
$LioyaCopilotEDU = @($LioyaCopilotEDUlisens).count
#Barnehagen 100
$B100CopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*barnehagenhundre.no") } | Select-Object DisplayName, UserPrincipalName
$B100CopilotEDU = @($B100CopilotEDUlisens).count
#Domkirkenes Barnehage
$DomkirkenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*domkirkens.no") } | Select-Object DisplayName, UserPrincipalName
$DomkirkenCopilotEDU = @($DomkirkenCopilotEDUlisens).count
#Einerabben Barnehage
$EinerabbenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*einerabben.no") } | Select-Object DisplayName, UserPrincipalName
$EinerabbenCopilotEDU = @($EinerabbenCopilotEDUlisens).count
#Ekrehagen Barnehage
$EkrehagenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*ekrehagen.com") } | Select-Object DisplayName, UserPrincipalName
$EkrehagenCopilotEDU = @($EkrehagenCopilotEDUlisens).count
#Kråkeslottet Barnehage
$KrakeslottetCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*kraakeslottet.no") } | Select-Object DisplayName, UserPrincipalName
$KrakeslottetCopilotEDU = @($KrakeslottetCopilotEDUlisens).count
#Kveldrovegen Barnehage
$KveldrovegenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*kveldrovegen.no") } | Select-Object DisplayName, UserPrincipalName
$KveldrovegenCopilotEDU = @($KveldrovegenCopilotEDUlisens).count
#Norrønna Barnehage
$NorronnaCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*norrona-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$NorronnaCopilotEDU = @($NorronnaCopilotEDUlisens).count
#Polarhagen Barnehage
$PolarhagenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*polarhagen-barnehage.no") } | Select-Object DisplayName, UserPrincipalName
$PolarhagenCopilotEDU = @($PolarhagenCopilotEDUlisens).count
#Soldagen Barnehage
$SoldagenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*Soldagenbhg.no") } | Select-Object DisplayName, UserPrincipalName
$SoldagenCopilotEDU = @($SoldagenCopilotEDUlisens).count
#Hamna Friluftsbarnehage
$HamnaCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*hamnafriluftsbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$HamnaCopilotEDU = @($HamnaCopilotEDUlisens).count
#Tusseladden Barnehage
$TusseladdenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*tusseladden.com") } | Select-Object DisplayName, UserPrincipalName
$TusseladdenCopilotEDU = @($TusseladdenCopilotEDUlisens).count
#Åsland Barnehage
$AslandCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*aabhg.no") } | Select-Object DisplayName, UserPrincipalName
$AslandCopilotEDU = @($AslandCopilotEDUlisens).count
#Skogstua Barnehage
$SkogstuaCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*skogstuabarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$SkogstuaCopilotEDU = @($SkogstuaCopilotEDUlisens).count
#Karveslettlia Barnehage
$KarveslettliaCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*karveslettlia.no") } | Select-Object DisplayName, UserPrincipalName
$KarveslettliaCopilotEDU = @($KarveslettliaCopilotEDUlisens).count
#Trollskogen Barnehage
$TrollskogenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*trollskogenbarn.no") } | Select-Object DisplayName, UserPrincipalName
$TrollskogenCopilotEDU = @($TrollskogenCopilotEDUlisens).count
#Kanutten Barnehage
$KanuttenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*kanuttenbh.no") } | Select-Object DisplayName, UserPrincipalName
$KanuttenCopilotEDU = @($KanuttenCopilotEDUlisens).count
#Ameliahaugen Barnehage
$AmeliahaugenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*ameliahaugen.no") } | Select-Object DisplayName, UserPrincipalName
$AmeliahaugenCopilotEDU = @($AmeliahaugenCopilotEDUlisens).count
#Bjerkaker Barnehage
$BjerkakerCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$BjerkakerCopilotEDU = @($BjerkakerCopilotEDUlisens).count
#Kulturbarnehagen
$KulturbarnehagenCopilotEDUlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $Microsoft_365_Copilot_EDU }) -and ($_.UserPrincipalName -like "*bjerkakerbarnehage.no") } | Select-Object DisplayName, UserPrincipalName
$KulturbarnehagenCopilotEDU = @($KulturbarnehagenCopilotEDUlisens).count

Write-Output "IBID: $IBIDCopilot" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Liøya Barnehage: $LioyaCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Barnehagen Hundre: $B100CopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Domkirkens Barnehage: $DomkirkenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Einerabben Barnehage: $EinerabbenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ekrehagen Barnehage: $EkrehagenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kråkeslottet Barnehage: $KrakeslottetCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kveldrovegen Barnehage: $KveldrovegenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Norrønna Barnehage: $NorronnaCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Polarhagen Barnehage: $PolarhagenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Soldagen Barnehage: $SoldagenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Tusseladden Barnehage: $TusseladdenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Åsland Barnehage: $AslandCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Skogstua Barnehage: $SkogstuaCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Karveslettlia Barnehage: $KarveslettliaCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Hamna Friluftsbarnehage: $HamnaCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Trollskogen Barnehage: $TrollskogenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kanutten Barnehage: $KanuttenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Ameliahaugen Barnehage: $AmeliahaugenCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Bjerkaker Barnehage: $BjerkakerCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "Kulturbarnehagen: $BjerkakerCopilotEDU" | out-file -append "$FilePath" -Encoding UTF8
"" | out-file -append "$FilePath" -Encoding ASCII

<#
#Sender epost med vedlegget
$EmailTo = "kim.skog@tromso.serit.no"
$EmailFrom = "noreply@itpartner.no"
$Subject = "Oversikt over alle lisenser hos IBID pr $Today" 
$Body = "Oversikt over alle lisenser hos IBID" 
$SMTPServer = "smtpgw.itpartner.no" 
$filenameAndPath = "$FilePath"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPmessage.Cc.Add("aleksander.simonsen@tromso.serit.no")
$attachment = New-Object System.Net.Mail.Attachment($filenameAndPath)
$SMTPMessage.Attachments.Add($attachment)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 465) 
$SMTPClient.EnableSsl = $true 
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential("itpartner_print", "S0mmerflorT21%"); 
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }
$SMTPClient.Send($SMTPMessage)
#>