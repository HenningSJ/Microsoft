function Get-YodeckScreen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ScreenId
    )

    $uri = "https://app.yodeck.com/api/v2/screens/$ScreenId/"

    try {
        $response = Invoke-YodeckRequest -Method GET -Uri $uri
        return $response
    }
    catch {
        Write-Error "Feil ved henting av screen ${ScreenId}: $_"
        throw
    }
}