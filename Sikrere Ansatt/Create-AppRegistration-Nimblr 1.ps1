# Her finner man Permission IDs:
# https://learn.microsoft.com/en-us/graph/permissions-reference

# Connect to Microsoft Graph with the required scopes
# 1. Install-PackageProvider -Name NuGet -Force
# 2. Install-Module PowerShellGet -AllowClobber -Force
# 3. Install-Module -Name Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force

# Check for and install required modules

# Check for and install required modules

# Function to install a module if it's not already installed
function Install-ModuleIfNotPresent {
    param (
        [string]$ModuleName
    )
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module '$ModuleName' not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name $ModuleName -Scope CurrentUser -Force -AllowClobber
    } else {
        Write-Host "Module '$ModuleName' is already installed." -ForegroundColor Green
    }
}

# Install NuGet provider if not available (needed for module installation)
if (!(Get-PackageProvider -Name "NuGet" -ErrorAction SilentlyContinue)) {
    Write-Host "NuGet provider not found. Installing..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -Force
}

# Check and install PowerShellGet and Microsoft.Graph modules if needed
Install-ModuleIfNotPresent -ModuleName "PowerShellGet"
Install-ModuleIfNotPresent -ModuleName "Microsoft.Graph"

# Connect to Microsoft Graph with the required scopes
Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All"

# Define Application Name
$appName = "Serit Sikrere Ansatt"

# Permission IDs for GroupMember.Read.All and User.Read.All
$varGroupMemberReadAll = "98830695-27a2-44f7-8c18-0c3ebc9698f6" # GroupMember.Read.All
$varUserReadAll = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All

# Create the Azure AD application
$app = New-MgApplication -DisplayName $appName

# Check if the application was created successfully
if ($app) {
    $appObjectId = $app.Id
    $app2ObjectId = $app.AppId

    # Create the Service Principal for the Azure AD application
    $servicePrincipal = New-MgServicePrincipal -AppId $app2ObjectId
    if ($servicePrincipal) {
        Write-Host "Service Principal created successfully" -ForegroundColor Green

        # Define the new Microsoft Graph permissions
        $newMicrosoftGraphPermissions = @(
            @{
                ResourceAppID = "00000003-0000-0000-c000-000000000000"; # Microsoft Graph App ID
                ResourceAccess = @(
                    @{
                        Id   = $varGroupMemberReadAll;
                        Type = "Role";
                    },
                    @{
                        Id   = $varUserReadAll;
                        Type = "Role";
                    }
                )
            }
        )

        # Update application with required permissions
        Update-MgApplication -ApplicationId $appObjectId -RequiredResourceAccess $newMicrosoftGraphPermissions

        # Indicate that the script is processing
        Write-Host "Updating application permissions, please wait..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30

        # Retrieve the Service Principal ID for Microsoft Graph
        $MSGraphServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq 'Microsoft Graph'"
        $MSGraphServicePrincipalObjectId = $MSGraphServicePrincipal.Id

        # Assign roles to the Service Principal
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSGraphServicePrincipalObjectId -PrincipalId $servicePrincipal.Id -ResourceId $MSGraphServicePrincipalObjectId -AppRoleId $varGroupMemberReadAll
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSGraphServicePrincipalObjectId -PrincipalId $servicePrincipal.Id -ResourceId $MSGraphServicePrincipalObjectId -AppRoleId $varUserReadAll

        # Create a new client secret
        $passwordCred = @{
            DisplayName = 'Serit'
            EndDateTime = (Get-Date).AddMonths(24)
        }
        $secret = Add-MgApplicationPassword -ApplicationId $appObjectId -PasswordCredential $passwordCred
        $ClientSecret = $secret.SecretText

        # Define the redirect URIs for web platform
        $redirectUris = @("https://nimblr.net/go/ad/reg")

        # Update the application with the web platform configuration and redirect URIs
        $webPlatform = @{
            RedirectUris = $redirectUris
        }
        Update-MgApplication -ApplicationId $appObjectId -Web $webPlatform

        Write-Host "Web redirect URI added successfully" -ForegroundColor Green

        # Output the tenant ID, client ID, and client secret for easy copying
        $tenantId = (Get-MgOrganization).Id
        Write-Host "===============================" -ForegroundColor Yellow
        Write-Host "Tenant ID: $tenantId" -ForegroundColor Cyan
        Write-Host "Client ID: $app2ObjectId" -ForegroundColor Cyan
        Write-Host "Client Secret: $ClientSecret" -ForegroundColor Cyan
        Write-Host "===============================" -ForegroundColor Yellow
        Write-Host "Application created and updated successfully." -ForegroundColor Green
    } else {
        Write-Host "Failed to create Service Principal" -ForegroundColor Red
    }
} else {
    Write-Host "Failed to create Application" -ForegroundColor Red
}


