

# Prerequisites:
# - Policy.Read.All
# - Policy.ReadWrite.AuthenticationMethod

# Step 1: Authenticate with Microsoft Graph
$authBody = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $env:varApplicationID
    client_secret = $env:varClientSecret
}
$response = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$env:varTenantID/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $authBody
$accessToken = $response.access_token

# Step 2: Get the current policy
$currentPolicy = Invoke-RestMethod -Method Get `
    -Uri "https://graph.microsoft.com/v1.0/policies/authenticationmethodspolicy" `
    -Headers @{Authorization = "Bearer $accessToken"}

# Debug: Display the current policy
Write-Host "Current Policy:" -ForegroundColor Cyan
$currentPolicy | ConvertTo-Json -Depth 10 | Write-Host

# Step 3: Extract existing excludeTargets
$currentExcludeTargets = @()

if ($currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.excludeTargets) {
    $currentExcludeTargets = @(
        $currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.excludeTargets | ForEach-Object {
            [PSCustomObject]@{
                id = $_.id
                targetType = $_.targetType
            }
        }
    )
}

# Step 4: Add the new user if not already present
if (-not ($currentExcludeTargets | Where-Object { $_.id -eq $env:varBreakGlassUserObjectId })) {
    $newExcludeTarget = [PSCustomObject]@{
        id = $env:varBreakGlassUserObjectId
        targetType = "user"
    }

    # Ensure $currentExcludeTargets is treated as an array
    $currentExcludeTargets = @($currentExcludeTargets)

    # Append the new object to the array
    $currentExcludeTargets += $newExcludeTarget
}

# Debug: Display the updated excludeTargets
Write-Host "Updated excludeTargets:" -ForegroundColor Cyan
$currentExcludeTargets | ConvertTo-Json -Depth 10 | Write-Host


# Step 5: Prepare the updated payload
$enforceRegistration = $currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.enforceRegistrationAfterAllowedSnoozes
if ($null -eq $enforceRegistration) {
    $enforceRegistration = $false
}

$payload = @(
    @{
        registrationEnforcement = @{
            authenticationMethodsRegistrationCampaign = @{
                snoozeDurationInDays = $currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.snoozeDurationInDays
                enforceRegistrationAfterAllowedSnoozes = $enforceRegistration
                state = $currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.state
                excludeTargets = $currentExcludeTargets
                includeTargets = $currentPolicy.registrationEnforcement.authenticationMethodsRegistrationCampaign.includeTargets
            }
        }
    }
) | ConvertTo-Json -Depth 10 -Compress

# Debug: Display the JSON payload
Write-Host "JSON Payload:" -ForegroundColor Cyan
Write-Host $payload

# Step 6: Send PATCH request with the updated payload
try {
    $response = Invoke-RestMethod -Method PATCH `
        -Uri "https://graph.microsoft.com/v1.0/policies/authenticationmethodspolicy" `
        -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"} `
        -Body $payload -ErrorAction Stop

    Write-Host "Policy updated successfully." -ForegroundColor Green
} catch {
    Write-Host "Error updating the policy: $($_.Exception.Message)" -ForegroundColor Red

    # Display detailed error response if available
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
}


