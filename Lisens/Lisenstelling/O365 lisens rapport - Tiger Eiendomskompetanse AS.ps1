<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet Tiger Eiendomskompetanse
Script av:      Kim Skog
============================================================================================
#>



#Koble fra eksisterende Microsoft Graph API
Disconnect-MgGraph
#Koble til Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All" -UseDeviceCode
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
#EXCHANGEENTERPRISE
$ExchangeOnlinePlan2 = "19ec0d23-8335-4cbd-94ac-6050e30712fa"
#Microsoft 365 Copilot
$Microsoft_365_Copilot = "639dec6b-bb19-468b-871c-c5c441c4b0cb"

#Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-Tiger Eiendom.txt"

Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = get-date

Write-Output "Oversikt over O365 lisenene til Tiger Eiendomskompetanse AS / Tromsø Næringsmegling AS pr $Today" | out-file -append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Sjekket antall lisenser og utildelte lisenser i tenanten
$SPBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$SPBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$SPBUnassigned = $SPBLicensecount+$SPBUnassignedcount
$EXO2Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "EXCHANGEENTERPRISE" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$EXO2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "EXCHANGEENTERPRISE"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$EXO2Unassigned = $EXO2Licensecount+$EXO2Unassignedcount
$M365COPLicensecount = Get-MgSubscribedSku  | Where-Object { $_.SkuPartNumber -eq "Microsoft_365_Copilot" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$M365COPUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "Microsoft_365_Copilot"} | Select-Object -Property ActiveUnits,ConsumedUnits,SkuPartNumber,@{L=’SpareLicenses’;E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object SkuPartNumber,SpareLicenses | Select-Object -ExpandProperty "SpareLicenses"
$M365COPUnassigned = $M365COPLicensecount+$M365COPUnassignedcount

#Lister opp totalt antall lisenser på kunde
write-output "Microsoft 365 Business Premium = Kunde har totalt $SPBLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Business Premium = Kunde har $SPBUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Exchange Online Plan 2 = Kunde har totalt $EXO2Licensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Exchange Online Plan 2 = Kunde har $EXO2Unassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
write-output "Microsoft 365 Copilot = Kunde har totalt $M365COPLicensecount lisenser" | out-file -append $FilePath -Encoding UTF8
write-output "Microsoft 365 Copilot = Kunde har $M365COPUnassigned utildelte lisenser" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII


#Lager liste over Oslobrukere
# Bjørn Einar Sundby = bes@tigereiendom.no 
# Eiliv Christensen = ec@tigereiendom.no
# Michael Færden = mf@tigereiendom.no
# Gøril Bergh = gb@tigereiendom.no
$OsloUsers = @("bes@tigereiendom.no", "ec@tigereiendom.no", "mf@tigereiendom.no", "gb@tigereiendom.no")
$Oslo = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object { $_.UserPrincipalName -in $OsloUsers } | Select-Object DisplayName, UserPrincipalName

#Lager array av Oslobrukere
$OsloUPNs = $Oslo.UserPrincipalName

#Lager filter for Oslobrukere med spesielle lisenser
$OsloCopilot = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $OsloUPNs -and $_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot} | Select-Object DisplayName, UserPrincipalName
$OsloCopilotcount = @($OsloCopilot).Count
$OsloEXOP2 = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $OsloUPNs -and $_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2} | Select-Object DisplayName, UserPrincipalName
$OsloEXOP2count = @($OsloEXOP2).Count
$OsloM365BP = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {  $_.UserPrincipalName -in $OsloUPNs -and $_.AssignedLicenses.SkuId -contains $SPB} | Select-Object DisplayName, UserPrincipalName
$OsloM365BPcount = @($OsloM365BP).Count


#Oslobrukere
$Oslo = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.UserPrincipalName -in @("bes@tigereiendom.no", "ec@tigereiendom.no", "mf@tigereiendom.no", "gb@tigereiendom.no" )} |Select-Object DisplayName, UserPrincipalName
$OsloM365BP = @($Oslo).Count
#region Opptelling av antall lisenser pr firma
#Microsoft 365 Business Premium
Write-Output "Microsoft 365 Business Premium" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Business Premium-lisens for Tiger Eiendomskompetanse AS
$OsloM365BPcount
# Hent brukere med SPB-lisens for Tromsø Næringsmegling
$NaringM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $SPB -and $_.UserPrincipalName -notin $OsloUsers} | Select-Object DisplayName, UserPrincipalName
$NaringM365BP = @($NaringM365BPlisens).Count
# Skriv resultatene til fil
Write-Output "Tiger Eiendomskompetanse AS (Oslo): $OsloM365BPcount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø Næringsmegling AS: $NaringM365BP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Exchange Online Plan 2
Write-Output "Exchange Online Plan 2" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Exchange Online Plan 2-lisens for Tiger Eiendomskompetanse AS
$OsloEXOP2count
# Hent brukere med SPB-lisens for Tromsø Næringsmegling
$NaringEXO2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2 -and $_.UserPrincipalName -notin $OsloUsers} | Select-Object DisplayName, UserPrincipalName
$NaringEXO2 = @($NaringEXO2lisens).Count
# Skriv resultatene til fil
Write-Output "Tiger Eiendomskompetanse AS (Oslo): $OsloEXOP2count" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø Næringsmegling AS: $NaringEXO2" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII

#Microsoft 365 Copilot
Write-Output "Microsoft 365 Copilot" | Out-File -Append $FilePath -Encoding UTF8
# Hent brukere med Microsoft 365 Copilot-lisens for Tiger Eiendomskompetanse AS
$OsloCopilotcount
# Hent brukere med SPB-lisens for Tromsø Næringsmegling
$NaringCOPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,Department" | Where-Object {$_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot -and $_.UserPrincipalName -notin $OsloUsers} | Select-Object DisplayName, UserPrincipalName
$NaringCOP = @($NaringCOPlisens).Count
# Skriv resultatene til fil
Write-Output "Tiger Eiendomskompetanse AS (Oslo): $OsloCopilotcount" | out-file -append $FilePath -Encoding UTF8
Write-Output "Tromsø Næringsmegling AS: $NaringCOP" | out-file -append $FilePath -Encoding UTF8
"" | out-file -append $FilePath -Encoding ASCII
#endregion

#region Lister opp lisensierte brukere
$MS365BPUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $SPB} | Select-Object DisplayName, UserPrincipalName
$EX02Users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $ExchangeOnlinePlan2} | Select-Object DisplayName, UserPrincipalName
$CopilotUsers = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {$_.AssignedLicenses -and $_.AssignedLicenses.SkuId -contains $Microsoft_365_Copilot} | Select-Object DisplayName, UserPrincipalName

#Lister opp brukere med Microsoft 365 Business Premium Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 BUSINESS PREMIUM LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $MS365BPUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Exchange Online Plan 2 Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED EXCHANGE ONLINE PLAN 2 LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $EX02Users | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8

#Lister opp brukere med Microsoft 365 Copilot Lisenser
Write-Output "OVERSIKT OVER BRUKERE MED MICROSOFT 365 COPILOT LISENS" | out-file -append "$FilePath" -Encoding UTF8
Write-Output "***************************************************************" | out-file -append "$FilePath" -Encoding UTF8
Write-Output $CopilotUsers | out-file -append "$FilePath" -Encoding UTF8
Write-Output "" | out-file -append "$FilePath" -Encoding ASCII
Write-Output "-----------------------------------------------------------" | out-file -append "$FilePath" -Encoding UTF8
#endregion