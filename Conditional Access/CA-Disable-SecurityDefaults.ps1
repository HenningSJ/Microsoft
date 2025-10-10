

# Prerequisits:
# - Policy.Read.All
# - Policy.ReadWrite.SecurityDefaults 


$GraphScope = "https://graph.microsoft.com/.default"
$GraphAPIUrl = "https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy"

# Get Access Token
$TokenBody = @{
    client_id     = $env:varApplicationID
    client_secret = $env:varClientSecret
    scope         = $GraphScope
    grant_type    = "client_credentials"
}
$AccessTokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$env:varTenantID/oauth2/v2.0/token" `
                                         -Method Post `
                                         -Body $TokenBody `
                                         -ContentType "application/x-www-form-urlencoded"
$AccessToken = $AccessTokenResponse.access_token

if (-not $AccessToken) {
    Write-Host "Failed to retrieve access token. Check your credentials." -ForegroundColor Red
    return
}

# Check if Security Defaults is Enabled
Write-Host "Checking Security Defaults status..." -ForegroundColor Yellow
$Response = Invoke-RestMethod -Uri $GraphAPIUrl `
                              -Method Get `
                              -Headers @{ Authorization = "Bearer $AccessToken" }

if ($Response.isEnabled -eq $true) {
    Write-Host "Security Defaults is currently ENABLED." -ForegroundColor Yellow
    Write-Host "Disabling Security Defaults..." -ForegroundColor Yellow

    # Disable Security Defaults
    $Body = @{
        isEnabled = $false
    } | ConvertTo-Json -Depth 10

    try {
        Invoke-RestMethod -Uri $GraphAPIUrl `
                          -Method Patch `
                          -Headers @{ Authorization = "Bearer $AccessToken"; "Content-Type" = "application/json" } `
                          -Body $Body
        # Add pause if Security Defaults was just disabled
        Start-Sleep 40
        Write-Host "Security Defaults has been successfully DISABLED." -ForegroundColor Green
    } catch {
        Write-Host "Failed to disable Security Defaults. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} elseif ($Response.isEnabled -eq $false) {
    Write-Host "Security Defaults is already DISABLED." -ForegroundColor Green
} else {
    Write-Host "Unable to determine Security Defaults status. Check permissions or API response." -ForegroundColor Red
}


