<#
.SYNOPSIS
    Automatiserer aktivering av Microsoft Report Button-integrasjonen for Nimblr Security.

.DESCRIPTION
    Scriptet utfører følgende:
      1. Oppretter en delt postboks for rapporterte e-poster
      2. Setter bruker-rapportering til å sende til den delte postboksen (+ Microsoft)
      3. Oppretter en app-registrering i Entra ID med Graph-tillatelsen Mail.Read
         (Application), gir admin consent og lager en client secret
      4. Oppretter en sikkerhetsgruppe og en Application Access Policy som låser
         appen til kun den delte postboksen (prinsippet om minste privilegium)
      5. Skriver ut Client ID / Tenant ID / Client secret for innliming i Nimblr-portalen

    Det som IKKE kan automatiseres:
      - Innliming av verdiene i Nimblr-portalen (Settings > Report Button)
      - Tilpasning av tilbakemeldingsmeldingen til brukeren (gjøres i security.microsoft.com)

.NOTES
    Krever moduler: ExchangeOnlineManagement, Microsoft.Graph
    Krever rettigheter: Global Administrator + Exchange Administrator
    Application Access Policy kan ta opptil 48 timer å tre i kraft.

.EXAMPLE
    .\Nimblr-ReportButton-Setup.ps1 -AdminUpn admin@dittdomene.no -Domain dittdomene.no
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string]$AdminUpn,
    [Parameter(Mandatory = $true)] [string]$Domain,

    [string]$SharedMbxAlias = "nimblr-report",
    [string]$SharedMbxName  = "Nimblr Report Mailbox",
    [string]$AppName        = "Nimblr-ReportButton-Integration",
    [string]$GroupName      = "API-Access-Group-V2 Security",
    [int]   $SecretMonths   = 24
)

$ErrorActionPreference = "Stop"

# Avledede verdier
$SharedMbx    = "$SharedMbxAlias@$Domain"
$GroupAlias   = "API-Access-Group-V2Security"
$GroupAddress = "$GroupAlias@$Domain"

# Faste IDer for Microsoft Graph
$GraphAppId   = "00000003-0000-0000-c000-000000000000"   # Microsoft Graph
$MailReadRole = "810c84a8-4a9e-49e6-bf7d-12d183f40d01"   # Mail.Read (Application)

function Write-Step { param($n, $msg) Write-Host "`n[$n] $msg" -ForegroundColor Cyan }

# ----------------------------------------------------------------------
# 0. Sjekk / installer moduler
# ----------------------------------------------------------------------
Write-Step 0 "Sjekker nødvendige moduler..."
foreach ($mod in @("ExchangeOnlineManagement", "Microsoft.Graph")) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "    Installerer $mod ..." -ForegroundColor Yellow
        Install-Module $mod -Scope allusers 
    }
}

# ----------------------------------------------------------------------
# 1. Koble til Exchange Online + opprett delt postboks
# ----------------------------------------------------------------------
Write-Step 1 "Kobler til Exchange Online..."
Connect-ExchangeOnline -UserPrincipalName $AdminUpn -ShowBanner:$false

Write-Step 1 "Oppretter delt postboks: $SharedMbx"
if (Get-Mailbox -Identity $SharedMbx -ErrorAction SilentlyContinue) {
    Write-Host "    Postboksen finnes allerede – hopper over." -ForegroundColor Yellow
} else {
    New-Mailbox -Shared -Name $SharedMbxName -Alias $SharedMbxAlias `
        -PrimarySmtpAddress $SharedMbx | Out-Null
    Write-Host "    Opprettet." -ForegroundColor Green
}

# ----------------------------------------------------------------------
# 2. Sett bruker-rapportering til delt postboks (+ Microsoft)
# ----------------------------------------------------------------------
Write-Step 2 "Konfigurerer ReportSubmissionPolicy..."
$policyParams = @{
    Identity                          = "DefaultReportSubmissionPolicy"
    EnableReportToMicrosoft           = $true
    ReportPhishToCustomizedAddress    = $true
    ReportPhishAddresses              = $SharedMbx
    ReportJunkToCustomizedAddress     = $true
    ReportJunkAddresses               = $SharedMbx
    ReportNotJunkToCustomizedAddress  = $true
    ReportNotJunkAddresses            = $SharedMbx
}
if (Get-ReportSubmissionPolicy -ErrorAction SilentlyContinue) {
    Set-ReportSubmissionPolicy @policyParams
} else {
    New-ReportSubmissionPolicy @policyParams
}

if (-not (Get-ReportSubmissionRule -ErrorAction SilentlyContinue)) {
    New-ReportSubmissionRule -Name "DefaultReportSubmissionRule" `
        -ReportSubmissionPolicy "DefaultReportSubmissionPolicy" -SentTo $SharedMbx | Out-Null
}
Write-Host "    Bruker-rapportering konfigurert. Verifiser i security.microsoft.com." -ForegroundColor Green

# ----------------------------------------------------------------------
# 3. App-registrering via Microsoft Graph
# ----------------------------------------------------------------------
Write-Step 3 "Kobler til Microsoft Graph..."
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All" -NoWelcome
$TenantId = (Get-MgContext).TenantId

Write-Step 3 "Oppretter app-registrering: $AppName"
$app = New-MgApplication -DisplayName $AppName -RequiredResourceAccess @{
    ResourceAppId  = $GraphAppId
    ResourceAccess = @(@{ Id = $MailReadRole; Type = "Role" })
}
Write-Host "    AppId: $($app.AppId)" -ForegroundColor Green

Write-Step 3 "Oppretter service principal og gir admin consent..."
$sp      = New-MgServicePrincipal -AppId $app.AppId
$graphSp = Get-MgServicePrincipal -Filter "appId eq '$GraphAppId'"

# Vent til service principal er propagert
Start-Sleep -Seconds 15
New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id `
    -PrincipalId $sp.Id -ResourceId $graphSp.Id -AppRoleId $MailReadRole | Out-Null
Write-Host "    Mail.Read (Application) gitt og samtykket." -ForegroundColor Green

Write-Step 3 "Oppretter client secret (gyldig $SecretMonths mnd)..."
$secret = Add-MgApplicationPassword -ApplicationId $app.Id -PasswordCredential @{
    DisplayName = "Nimblr-Secret"
    EndDateTime = (Get-Date).AddMonths($SecretMonths)
}

# ----------------------------------------------------------------------
# 4. Sikkerhetsgruppe + Application Access Policy
# ----------------------------------------------------------------------
Write-Step 4 "Oppretter sikkerhetsgruppe: $GroupAddress"
if (Get-DistributionGroup -Identity $GroupAddress -ErrorAction SilentlyContinue) {
    Write-Host "    Gruppen finnes allerede – hopper over." -ForegroundColor Yellow
} else {
    New-DistributionGroup -Name $GroupName -Alias $GroupAlias -Type Security `
        -PrimarySmtpAddress $GroupAddress -Members $SharedMbx | Out-Null
    Write-Host "    Opprettet. Venter på propagering..." -ForegroundColor Green
    Start-Sleep -Seconds 30
}

Write-Step 4 "Oppretter Application Access Policy (låser appen til postboksen)..."
New-ApplicationAccessPolicy -AppId $app.AppId -PolicyScopeGroupId $GroupAddress `
    -AccessRight RestrictAccess `
    -Description "Restrict Nimblr app to shared mailbox only" | Out-Null
Write-Host "    Policy opprettet (kan ta opptil 48 timer å tre i kraft)." -ForegroundColor Green

# ----------------------------------------------------------------------
# 5. Resultat – lim inn i Nimblr-portalen
# ----------------------------------------------------------------------
Write-Host "`n==================================================================" -ForegroundColor Magenta
Write-Host " LIM INN I NIMBLR-PORTALEN  (Settings > Report Button)" -ForegroundColor Magenta
Write-Host "==================================================================" -ForegroundColor Magenta
Write-Host (" Application (client) ID : {0}" -f $app.AppId)
Write-Host (" Directory (tenant) ID   : {0}" -f $TenantId)
Write-Host (" Client secret           : {0}" -f $secret.SecretText)
Write-Host (" Delt postboks           : {0}" -f $SharedMbx)
Write-Host "==================================================================" -ForegroundColor Magenta
Write-Host " VIKTIG: Client secret vises kun nå. Lagre den et trygt sted." -ForegroundColor Yellow
Write-Host " Test policy:  Test-ApplicationAccessPolicy -AppId $($app.AppId) -Identity $SharedMbx`n" -ForegroundColor DarkGray

# Frakoble
Disconnect-ExchangeOnline -Confirm:$false | Out-Null
Disconnect-MgGraph | Out-Null
