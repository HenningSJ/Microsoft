

# Prerequisites:
# - Group.ReadWrite.All

##########################################################################
###       Creates a dynamic group with a membership rule              ####
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

# Step 2: Define the new dynamic group details
$groupName = "SelfServicePasswordReset-AlleAnsatte-Dynamic"

# Construct dynamic membership rule
$dynamicMembershipRule = "(user.assignedPlans -any (assignedPlan.servicePlanId -eq `"`c7699d2e-19aa-44de-8edf-1736da088ca1`" -and assignedPlan.capabilityStatus -eq `"`Enabled`")) -and user.userPrincipalName -notStartsWith `"`xavier.westli@`""


$groupDetails = @(
    @{
        description       = "Henter alle aktive kontoer med Sharepoint lisens. Break-Glass konto er ekskludert."
        displayName       = $groupName
        groupTypes        = @("DynamicMembership")
        mailEnabled       = $false
        mailNickname      = "mfassprexclude"
        securityEnabled   = $true
        membershipRule    = $dynamicMembershipRule
        membershipRuleProcessingState = "On"
    }
) | ConvertTo-Json -Depth 3 -Compress

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

    Write-Host "Azure AD Dynamic Group created successfully!" -ForegroundColor Green
    $groupId = $createGroupResponse.id
    Write-Host "Group ID: $groupId" -ForegroundColor Green
} catch {
    Write-Host "Error creating Azure AD Dynamic Group: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $reader.BaseStream.Position = 0
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body: $responseBody" -ForegroundColor Yellow
    }
    return
}


