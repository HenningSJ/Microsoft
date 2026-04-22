function Invoke-YodeckRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Uri,

        [object]$Body
    )

    if (-not $env:YODECK_TOKEN) {
        throw "Miljøvariabelen YODECK_TOKEN er ikke satt."
    }

    $headers = @{
        Authorization  = "Token YODECK_TOKEN:$($env:YODECK_TOKEN)"
        Accept         = "application/json"
        "Content-Type" = "application/json"
    }

    Write-Verbose "Yodeck request: $Method $Uri"

    if ($Body) {
        Invoke-RestMethod `
            -Method  $Method `
            -Uri     $Uri `
            -Headers $headers `
            -Body    ($Body | ConvertTo-Json -Depth 10)
    }
    else {
        Invoke-RestMethod `
            -Method  $Method `
            -Uri     $Uri `
            -Headers $headers
    }
}
