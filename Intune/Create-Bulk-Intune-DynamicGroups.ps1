

Import-Module AzureADPreview  

Connect-AzureAD

$GroupExists = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Android-devices'"
$GroupExists1 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Windows-devices'"
$GroupExists2 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-iOS-devices'"
$GroupExists3 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-MacOS-devices'"
$GroupExists4 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Autopilot-devices'"
$GroupExists5 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Rollout'"
$GroupExists6 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Corporate-iPad-devices'"
$GroupExists7 = Get-AzureADGroup -Filter "DisplayName eq 'Intune-All-Corporate-iPhone-devices'"

if ($GroupExists -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Android-devices" -Description "Alle android enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -match ""Android"")" -membershipRuleProcessingState "On"
}
if ($GroupExists1 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Windows-devices" -Description "Alle windows enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -match ""Windows"")" -membershipRuleProcessingState "On"
}
if ($GroupExists2 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-iOS-devices" -Description "Alle iOS enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -eq ""iPad"") or (device.deviceOSType -eq ""iPhone"")" -membershipRuleProcessingState "On"
}
if ($GroupExists3 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-MacOS-devices" -Description "Alle Mac enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -eq ""MacMDM"")" -membershipRuleProcessingState "On"
}
if ($GroupExists4 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Autopilot-devices" -Description "Alle enheter som er innrullert ved hjelp av autopilot." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.devicePhysicalIDs -any _ -contains ""[ZTDId]"")" -membershipRuleProcessingState "On"
}
if ($GroupExists5 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Rollout" -Description "Alle aktiverte brukere med intune lisens." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(user.assignedPlans -any (assignedPlan.service -eq ""SCO"" -and assignedPlan.capabilityStatus -eq ""Enabled""))" -membershipRuleProcessingState "On"
}
if ($GroupExists6 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Corp-iPad-devices" -Description "Alle Corporate iPad enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -eq ""iPad"" -and device.deviceOwnership -eq ""Company"")" -membershipRuleProcessingState "On"
}
if ($GroupExists7 -ne $NULL)
{
    Write-Host "Group has already been created." -ForegroundColor Green
} else
{
    New-AzureADMSGroup -DisplayName "Intune-All-Corp-iPhone-devices" -Description "Alle Corporate iPhone enheter." -MailEnabled $False -MailNickName "group" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -eq ""iPhone"" -and device.deviceOwnership -eq ""Company"")" -membershipRuleProcessingState "On"
}

