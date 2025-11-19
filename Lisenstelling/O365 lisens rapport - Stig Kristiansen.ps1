<#
=============================================================================================
Name:           Office 365 license reporting tool
Description:    Dette scriptet gir oversikt over alle lisenser som er tilknyttet Stig Kristiansen
Script av:      Kim Skog (Oppdatert med Copilot av Henning)
=============================================================================================
#>

# Koble fra eksisterende Microsoft Graph API
Disconnect-MgGraph
# Koble til Microsoft Graph API
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# SKU-ID-er
$SPB = "cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46"              # Microsoft 365 Business Premium
$PROJECTPROFESSIONAL = "53818b1b-4a27-454b-8896-0dba576410e6" # Project Plan 3
$VISIOCLIENT = "c5928f49-12ba-48f7-ada3-0d743a3601d5"      # Visio Plan 2
$COPILOT = "639dec6b-bb19-468b-871c-c5c441c4b0cb"          # Microsoft 365 Copilot

# Setter filepath hvor rapportfilen skal lagres
$FilePath = "C:\temp\O365Users-Maskinentreprenør Stig Kristiansen.txt"
Remove-Item -Path $FilePath -Force -ErrorAction Continue
$Today = Get-Date

Write-Output "Oversikt over O365 lisenene til Maskinentreprenør Stig Kristiansen / Vacumkjempen pr $Today" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "-----------------------------------------------------------" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

# Sjekket antall lisenser og utildelte lisenser i tenanten
# Business Premium
$SPBLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "SPB" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$SPBUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "SPB"} | Select-Object -Property ActiveUnits,ConsumedUnits,@{L='SpareLicenses';E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object -ExpandProperty "SpareLicenses"
$SPBUnassigned = $SPBLicensecount + $SPBUnassignedcount

# Project Plan 3
$PROJLicensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "PROJECTPROFESSIONAL" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$PROJUnassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "PROJECTPROFESSIONAL"} | Select-Object -Property ActiveUnits,ConsumedUnits,@{L='SpareLicenses';E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object -ExpandProperty "SpareLicenses"
$PROJUnassigned = $PROJLicensecount + $PROJUnassignedcount

# Visio Plan 2
$VIS2Licensecount = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "VISIOCLIENT" } | Select-Object -ExpandProperty PrepaidUnits | Select-Object -ExpandProperty "Enabled"
$VIS2Unassignedcount = Get-MgSubscribedSku | Where-Object {($_.SkuPartnumber) -eq "VISIOCLIENT"} | Select-Object -Property ActiveUnits,ConsumedUnits,@{L='SpareLicenses';E={$_.ActiveUnits - $_.ConsumedUnits}} | Select-Object -ExpandProperty "SpareLicenses"
$VIS2Unassigned = $VIS2Licensecount + $VIS2Unassignedcount

# Copilot
$COPILOTSku = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq "M365COPILOT" }
    # Totalt antall lisenser
$COPILOTLicensecount = $COPILOTSku.PrepaidUnits.Enabled
    # Utildelte lisenser (ActiveUnits - ConsumedUnits)
$COPILOTUnassigned = $COPILOTSku.ActiveUnits - $COPILOTSku.ConsumedUnits

# Lister opp totalt antall lisenser på kunde
Write-Output "Microsoft 365 Business Premium = Kunde har totalt $SPBLicensecount lisenser" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Microsoft 365 Business Premium = Kunde har $SPBUnassigned utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

Write-Output "Planner and Project Plan 3 = Kunde har totalt $PROJLicensecount lisenser" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Planner and Project Plan 3 = Kunde har $PROJUnassigned utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

Write-Output "Visio Plan 2 = Kunde har totalt $VIS2Licensecount lisenser" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Visio Plan 2 = Kunde har $VIS2Unassigned utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

Write-Output "Microsoft 365 Copilot = Kunde har totalt $COPILOTLicensecount lisenser" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Microsoft 365 Copilot = Kunde har $COPILOTUnassigned utildelte lisenser" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII


Write-Output "-----------------------------------------------------------" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

# Opptelling av antall lisenser pr firma
# Business Premium
Write-Output "Microsoft 365 Business Premium" | Out-File -Append $FilePath -Encoding UTF8
$MSKM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKM365BP = @($MSKM365BPlisens).Count + 1
$VACM365BPlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $SPB }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACM365BP = @($VACM365BPlisens).Count
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKM365BP" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACM365BP" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

# Project Plan 3
Write-Output "Planner and Project Plan 3" | Out-File -Append $FilePath -Encoding UTF8
$MSKPROJlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKPROJ = @($MSKPROJlisens).Count
$VACPROJlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $PROJECTPROFESSIONAL }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACPROJ = @($VACPROJlisens).Count
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKPROJ" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACPROJ" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

# Visio Plan 2
Write-Output "Visio Plan 2" | Out-File -Append $FilePath -Encoding UTF8
$MSKVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKVIS2 = @($MSKVIS2lisens).Count
$VACVIS2lisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $VISIOCLIENT }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACVIS = @($VACVIS2lisens).Count
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKVIS2" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACVIS" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII

# Copilot
Write-Output "Microsoft 365 Copilot" | Out-File -Append $FilePath -Encoding UTF8
$MSKCOPILOTlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $COPILOT }) -and ($_.UserPrincipalName -like "*@stig-kristiansen.no") } | Select-Object DisplayName, UserPrincipalName
$MSKCOPILOT = @($MSKCOPILOTlisens).Count
$VACCOPILOTlisens = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses" | Where-Object {($_.AssignedLicenses | Where-Object { $_.SkuId -eq $COPILOT }) -and ($_.UserPrincipalName -like "*@vacumkjempen.no") } | Select-Object DisplayName, UserPrincipalName
$VACCOPILOT = @($VACCOPILOTlisens).Count
Write-Output "Maskinentreprenør Stig Kristiansen: $MSKCOPILOT" | Out-File -Append $FilePath -Encoding UTF8
Write-Output "Vacumkjempen VVS: $VACCOPILOT" | Out-File -Append $FilePath -Encoding UTF8
"" | Out-File -Append $FilePath -Encoding ASCII
