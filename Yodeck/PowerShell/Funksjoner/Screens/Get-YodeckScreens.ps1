function Get-YodeckScreens {
    [CmdletBinding()]
    param(
        [int]$Limit,
        [int]$Offset = 0,
        [string]$WorkspaceId
    )

    $uri = "https://app.yodeck.com/api/v2/screens/"
    
    # Bygg query parameters
    $queryParams = @()
    if ($PSBoundParameters.ContainsKey('Limit')) {
        $queryParams += "limit=$Limit"
    }
    if ($Offset -gt 0) {
        $queryParams += "offset=$Offset"
    }
    if ($WorkspaceId) {
        $queryParams += "workspace=$WorkspaceId"
    }
    
    if ($queryParams.Count -gt 0) {
        $uri += "?" + ($queryParams -join "&")
    }

    try {
        $response = Invoke-YodeckRequest -Method GET -Uri $uri
        return $response
    }
    catch {
        Write-Error "Feil ved henting av screens: $_"
        throw
    }
}
