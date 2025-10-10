

# Prerequisites:
# - Group.ReadWrite.All

##########################################################################
###       Creates group and adds break glass account as member        ####
##########################################################################

# Step 1: Authenticate and get an access token
$authBody = @{
    grant_type    = "client_credentials"
    client_id     = $env:varApplicationID
    client_secret = $env:varClientSecret
    scope         = "https://graph.microsoft.com/.default"
}
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$env:varTenantID/oauth2/v2.0/token" -Body $authBody -ContentType "application/x-www-form-urlencoded"
$accessToken = $tokenResponse.access_token

# Step 2: Define the new group details
$groupName = "MFA-SystemPrefered-Exclude"
$groupDetails = @{
    description = "Brukes til ekskludering fra system prefered Microsoft Authenticator"
    displayName = $groupName
    groupTypes = @() # Empty array means it's a security group
    mailEnabled = $false
    mailNickname = "mfasystempreferedexclude"
    securityEnabled = $true
} | ConvertTo-Json -Depth 3 -Compress

# Step 3: Create the group
$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

try {
    $createGroupResponse = Invoke-RestMethod -Method Post `
        -Uri "https://graph.microsoft.com/v1.0/groups" `
        -Headers $headers `
        -Body $groupDetails

    Write-Host "Azure AD Security Group created successfully!" -ForegroundColor Green
    $groupId = $createGroupResponse.id
    Write-Host "Group ID: $groupId" -ForegroundColor Green
} catch {
    Write-Host "Error creating Azure AD Security Group: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
    return
}

# Step 4: Add Break Glass account as member to group
$memberObjectId = $env:varBreakGlassUserObjectId 
$addMemberBody = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$memberObjectId"
} | ConvertTo-Json -Depth 3 -Compress

Write-Host "Adding member with body:" -ForegroundColor Yellow
Write-Host $addMemberBody -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Method Post `
        -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref" `
        -Headers $headers `
        -Body $addMemberBody

    Write-Host "Member added successfully!" -ForegroundColor Green
} catch {
    Write-Host "Error adding member: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}


# Step 5: Exclude Group from System-preferred multifactor authentication 

$payload = @"
{
    "systemCredentialPreferences": {
        "state": "enabled",
        "excludeTargets": [
            {
                "id": "$groupId",
                "targetType": "group"
            }
        ],
        "includeTargets": [
            {
                "id": "all_users",
                "targetType": "group"
            }
        ]
    }
}
"@

$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

$response = Invoke-RestMethod -Method PATCH `
    -Uri "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy" `
    -Headers $headers `
    -Body $payload

Write-Host "Policy updated successfully." -ForegroundColor Green
$response | ConvertTo-Json -Depth 10 | Write-Host



