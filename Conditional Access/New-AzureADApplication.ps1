
# Connect to Microsoft Graph with the required scopes
# 1. Install-PackageProvider -Name NuGet -Force
# 2. Install-Module PowerShellGet -AllowClobber -Force
# 3. Install-Module -Name Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force

Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All", "Directory.Read.All"

# HUSK - cd '.\Conditional Access\'
# TestConnection: Get-MgUser

# Husk å kjøre "Set-SecureScoreStatus" etter dette scriptet er kjørt

# ENDRES
$tenantId = "0c3ea581-bd68-451e-8cac-129d02f0fcdd"
$domene = "@idemo2.no"


# Verdier
$appName = "Create-ConditionalAccess"
$varApplicationReadAllId = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"
$varDirectoryReadWriteAllId = "19dbc75e-c2e2-444c-a770-ec69d8559fc7"
$varPolicyReadAllId = "246dd0d5-5bd0-4def-940b-0421030a5b68"
$varPolicyReadWriteConditionalAccessId = "01c0a623-fc9b-48e9-b794-0756f8e8f067"
$varRoleManagementReadWriteDirectoryId = "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8"
$varPolicyReadWriteAuthenticationMethodId = "29c18626-4985-4dcd-85c0-193eef327366"
$varPolicyReadWriteSecurityDefaultsId = "1c6e93a6-28e2-4cbb-9f64-1a46a821124d"

# Create the Azure AD application
$app = New-MgApplication -DisplayName $appName
$appObjectId = $app.Id
$app2ObjectId = $app.appId

# Creates the Service Principal for the Azure AD application
New-MgServicePrincipal -AppId $app2ObjectId

## Azure AD Graph's globally unique appId is 00000002-0000-0000-c000-000000000000 identified by the ResourceAppId
$AzureADGraphAppId = "00000002-0000-0000-c000-000000000000"
$MicrosoftGraphAppId = "00000003-0000-0000-c000-000000000000"

## Replace a05f9f7f-4377-4915-bbd0-5fe8f9517046 with the object ID of the app you wish to add new permissions to
$clientObjectId = $appObjectId

## Define the new Microsoft Graph permissions to be added to the target client
$newMicrosoftGraphPermissions = @{  
    ResourceAppID  = $MicrosoftGraphAppId;
    ResourceAccess = @(
        @{
            # App - Application.Read.All
            id   = $varApplicationReadAllId;
            type = "Role";
        }
        @{
            # App - Directory.ReadWrite.All
            id   = $varDirectoryReadWriteAllId;
            type = "Role";
        }
        @{
            # App - Policy.Read.All
            id   = $varPolicyReadAllId;
            type = "Role";
        }
        @{
            # App - Policy.ReadWrite.ConditionalAccess
            id   = $varPolicyReadWriteConditionalAccessId;
            type = "Role";
        }
        @{
            # App - RoleManagement.ReadWrite.Directory
            id   = $varRoleManagementReadWriteDirectoryId;
            type = "Role";
        }
        @{
            # App - Policy.ReadWrite.AuthenticationMethod
            id   = $varPolicyReadWriteAuthenticationMethodId;
            type = "Role";
        }
        @{
            # App - Policy.ReadWrite.SecurityDefaults
            id   = $varPolicyReadWriteSecurityDefaultsId;
            type = "Role";
        }
    )
}

$clientApp = Get-MgApplication -ApplicationId $clientObjectId

## Get the existing permissions of the application
$existingResourceAccess = $clientApp.RequiredResourceAccess

## If the app has no existing permissions, or no existing permissions from our new permissions resource
if ( ([string]::IsNullOrEmpty($existingResourceAccess) ) -or ($existingResourceAccess | Where-Object { $_.ResourceAppId -eq $AzureADGraphAppId } -eq $null) ) {
    $existingResourceAccess += $newAzureADGraphPermissions
    if ($existingResourceAccess | Where-Object { $_.ResourceAppId -eq $MicrosoftGraphAppId } -eq $null) {
        $existingResourceAccess += $newMicrosoftGraphPermissions
        Update-MgApplication -ApplicationId $clientObjectId -RequiredResourceAccess $existingResourceAccess
    }
    else {
        ## If the app already has existing permissions from our new permissions resource
        $existingResourceAccess = $existingResourceAccess + $newAzureADGraphPermissions + $newMicrosoftGraphPermissions
        Update-MgApplication -ApplicationId $clientObjectId -RequiredResourceAccess $existingResourceAccess
    }
}

Start-Sleep 30

# Retrieve the object ID of the service principal for the application
$AppServicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$appName'"
$AppServicePrincipalId = $AppServicePrincipal.Id

# Retrieve the object ID of the service principal for Microsoft Graph
$MSGraphServicePrincipal = Get-MgServicePrincipal -Filter "displayName eq 'Microsoft Graph'"
$MSGraphServicePrincipalObjectId = $MSGraphServicePrincipal.Id

# Define an array of app role IDs you want to assign
$appRoleIds = @(
    $varApplicationReadAllId,
    $varDirectoryReadWriteAllId,
    $varPolicyReadAllId,
    $varPolicyReadWriteConditionalAccessId,
    $varRoleManagementReadWriteDirectoryId,
    $varPolicyReadWriteAuthenticationMethodId
    $varPolicyReadWriteSecurityDefaultsId
    # Add more role IDs as needed
)

# Loop through each app role ID and assign it to the service principal
foreach ($appRoleId in $appRoleIds) {
    $params = @{
        "PrincipalId" = $AppServicePrincipalId
        "ResourceId"  = $MSGraphServicePrincipalObjectId
        "AppRoleId"   = $appRoleId
    }

    # Assign the application role to the service principal
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $MSGraphServicePrincipalObjectId -BodyParameter $params
}

# Create a new client secret
$passwordCred = @{
    displayName = 'Serit'
    endDateTime = (Get-Date).AddMonths(24)
 }
 $secret = Add-MgApplicationPassword -applicationId $appObjectId -PasswordCredential $passwordCred

# Output the secret
# IMPORTANT: Store this value securely. It's not retrievable after you close the PowerShell session.
$ClientSecret = $secret.SecretText

$env:varClientSecret = $ClientSecret
$env:varApplicationID = $app2ObjectId
$env:varTenantID = $tenantId
$env:varDomain = $domene 
$env:varDeleteApplication = $appObjectId

Start-Sleep 30

& ".\CA-Disable-SecurityDefaults.ps1"
& ".\CA-Create-BreakGlass-Account.ps1"

