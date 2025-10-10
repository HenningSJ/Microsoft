
# Prerequisits: 
# - RoleManagement.ReadWrite.Directory
# - Directory.ReadWrite.All


$tokenUrl = "https://login.microsoftonline.com/$env:varTenantID/oauth2/v2.0/token"
$scope = "https://graph.microsoft.com/.default"

$password = "SVYq@3*Qmc7:F:#Y2Dh%HD&,rw#~uVd+d:GzOCwR&y|5ikRSHWXZa?'Norz#y2|B6%ID5h&s"

# Get access token
$body = @{
    client_id     = $env:varApplicationID
    scope         = $scope
    client_secret = $env:varClientSecret
    grant_type    = "client_credentials"
}
$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
$token = $response.access_token

# Create a new user using Graph API
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$userBody = @{
    accountEnabled = $true
    displayName = "Xavier Westli"
    mailNickname = "Xavier.Westli"
    userPrincipalName = "xavier.westli" + $env:varDomain
    passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $password
    }    
} | ConvertTo-Json -Depth 3

Start-Sleep 20

$newUser2 = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/users" -Headers $headers -Body $userBody

# Output new user details
$newUser2

# Define the URI for the role assignments endpoint
$uri = "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments"

# Prepare the headers with authorization and content type
$headers = @{
    "Authorization" = "Bearer $token" # Replace $token with your actual bearer token
    "Content-Type"  = "application/json"
}

# Define the body of the request using the provided payload
$roleAssignmentBody = @{
    "@odata.type" = "#microsoft.graph.unifiedRoleAssignment"
    "roleDefinitionId" = "62e90394-69f5-4237-9190-012177145e10"  # Global Administrator ID
    "principalId" = "$($newUser2.id)"
    "directoryScopeId" = "/"
} | ConvertTo-Json -Depth 10

# Send the request
try {
    $response = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $roleAssignmentBody
    Write-Host "Role assignment created successfully."
    Write-Host ($response | ConvertTo-Json)
} catch {
    Write-Host "Error creating role assignment."
    Write-Host $_.Exception.Message
    if ($_.Exception.Response) {
        $responseStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($responseStream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body:"
        Write-Host $responseBody
    }
}

Start-Sleep 30

$env:varBreakGlassUserObjectId = $newUser2.id
$env:varBreakGlassAccountPassword = $password

& ".\CA-Template-Block-Legacy.ps1"
& ".\CA-Template-MFA-ADMINS.ps1"
& ".\CA-Template-MFA-GUESTS.ps1"
& ".\CA-Template-MFA-USERS.ps1"
& ".\CA-Exclude-BreakGlass-RegistrationCampaign.ps1"
& ".\CA-Create-SSPR-SecurityGroup.ps1"
& ".\CA-Create-SystemPrefered-SecurityGroup.ps1"
& ".\Delete-AzureADAppRegistration.ps1"


Write-Host @"
Husk å dokumentere Break Glass konto i KeePass:
- Brukernavn: $("xavier.westli" + $env:varDomain)
- Passord: $password
"@ -ForegroundColor Yellow


