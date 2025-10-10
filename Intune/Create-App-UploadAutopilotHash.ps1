

# Connect to Microsoft Graph with the required scopes
# 1. Install-PackageProvider -Name NuGet -Force
# 2. Install-Module PowerShellGet -AllowClobber -Force
# 3. Install-Module -Name Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force

# Connect to Microsoft Graph with the required scopes
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

# Define Application Name
$appName = "Upload Autopilot Hash Test"

# Permissions ID for DeviceManagementServiceConfig
$varDeviceManagementServiceConfigReadWriteAll = "5ac13192-7ace-4fcf-b828-1a26f28068ee"

# Create the Azure AD application and enable 'Allow public client flows' as a switch
$app = New-MgApplication -DisplayName $appName -IsFallbackPublicClient

# Check if the application was created successfully
if ($app) {
    $appObjectId = $app.Id
    $app2ObjectId = $app.AppId

    # Create the Service Principal for the Azure AD application
    $servicePrincipal = New-MgServicePrincipal -AppId $app2ObjectId
    if ($servicePrincipal) {
        Write-Host "Service Principal created successfully" -ForegroundColor Green

        # Define the new Microsoft Graph permissions
        $newMicrosoftGraphPermissions = @{
            ResourceAppID = "00000003-0000-0000-c000-000000000000"; # Microsoft Graph App ID
            ResourceAccess = @(
                @{
                    Id   = $varDeviceManagementServiceConfigReadWriteAll;
                    Type = "Role";
                }
            )
        }

        # Get existing permissions of the application
        $clientApp = Get-MgApplication -ApplicationId $appObjectId
        $existingResourceAccess = $clientApp.RequiredResourceAccess

        # Update or add new permissions
        if (!$existingResourceAccess) {
            $existingResourceAccess = @()
        }
        $existingResourceAccess += $newMicrosoftGraphPermissions
        Update-MgApplication -ApplicationId $appObjectId -RequiredResourceAccess $existingResourceAccess

        Start-Sleep -Seconds 30

        # Retrieve the Service Principal ID for Microsoft Graph
        $MSGraphServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq 'Microsoft Graph'"
        $MSGraphServicePrincipalObjectId = $MSGraphServicePrincipal.Id

        # Assign roles to the Service Principal
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSGraphServicePrincipalObjectId -PrincipalId $servicePrincipal.Id -ResourceId $MSGraphServicePrincipalObjectId -AppRoleId $varDeviceManagementServiceConfigReadWriteAll

        # Update the application to include mobile and desktop platform
        $publicClient = @{
            RedirectUris = @("https://login.microsoftonline.com/common/oauth2/nativeclient")
        }
        Update-MgApplication -ApplicationId $appObjectId -PublicClient $publicClient

        # Create a new client secret
        $passwordCred = @{
            DisplayName = 'Serit'
            EndDateTime = (Get-Date).AddMonths(24)
        }
        $secret = Add-MgApplicationPassword -ApplicationId $appObjectId -PasswordCredential $passwordCred
        $ClientSecret = $secret.SecretText

        # Output the client secret securely
        Write-Host "Client Secret: $ClientSecret" -ForegroundColor Green
        Write-Host "Application updated with mobile and desktop platform settings." -ForegroundColor Green
    } else {
        Write-Host "Failed to create Service Principal" -ForegroundColor Red
    }
} else {
    Write-Host "Failed to create Application" -ForegroundColor Red
}


