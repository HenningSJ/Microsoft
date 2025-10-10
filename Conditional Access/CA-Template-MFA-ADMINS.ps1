
# Prerequisits:
# - Policy.Read.All
# - Policy.ReadWrite.ConditionalAccess
# - Application.Read.Allo


# Ensure the BreakGlassUserObjectId environment variable is set
if ([string]::IsNullOrWhiteSpace($env:varBreakGlassUserObjectId)) {
    Write-Error "BreakGlassUserObjectId is not set or is empty."
    exit
}

# Read the JSON file
$jsonFilePath = ".\Require multifactor authentication for admins.json"
try {
    $json = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
} catch {
    Write-Error "Failed to read or parse the JSON file at '$jsonFilePath'. Error: $_"
    exit
}

# Clear the excludeUsers array and add the current BreakGlassUserObjectId
$json.conditions.users.excludeUsers = @($env:varBreakGlassUserObjectId)

# Convert the object back to JSON, ensuring that it does not convert empty arrays to null
$jsonString = $json | ConvertTo-Json -Depth 100 -Compress

# Write the JSON back to the file, using -Force to ensure it overwrites any existing file
$jsonString | Set-Content -Path $jsonFilePath -Force


$tokenUrl = "https://login.microsoftonline.com/$env:varTenantID/oauth2/v2.0/token"
$scope = "https://graph.microsoft.com/.default"

# Get access token
$body = @{
    client_id     = $env:varApplicationID
    scope         = $scope
    client_secret = $env:varClientSecret
    grant_type    = "client_credentials"
}

$response = Invoke-RestMethod -Method Post -Uri $tokenUrl -Body $body
$token = $response.access_token

# Create Conditional Access Policy
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$templateContent = Get-Content -Path ".\Require multifactor authentication for admins.json" -Raw
$conditionalAccessUrl = "https://graph.microsoft.com/beta/conditionalAccess/policies"
$response = Invoke-RestMethod -Method Post -Uri $conditionalAccessUrl -Headers $headers -Body $templateContent

# Output the response (you can also handle this as desired)
$response


