# --- Konfig ---
$TokenLabel = "Yodeck-Token"   # din label i Yodeck
$BaseUrl    = "https://app.yodeck.com"
$StartUrl   = "$BaseUrl/api/v2/screens?limit=100&offset=0"

if (-not $env:YODECK_TOKEN) { throw "Mangler miljøvariabel YODECK_TOKEN." }

$headers = @{
  Authorization = "Token $TokenLabel`:$($env:YODECK_TOKEN)"
  Accept        = "application/json"
}

function Get-AllYodeckScreens {
  param([string]$Url)

  $all  = New-Object System.Collections.Generic.List[object]
  $next = $Url

  while ($next) {
    try {
      $page = Invoke-RestMethod -Method GET -Uri $next -Headers $headers -ErrorAction Stop
    }
    catch {
      # Enkel throttle-håndtering (429). [1](https://powershellfaqs.com/set-and-get-environment-variables-in-powershell/)
      if ($_.Exception.Response -and $_.Exception.Response.StatusCode.Value__ -eq 429) {
        $retryAfter = $_.Exception.Response.Headers["Retry-After"]
        if (-not $retryAfter) { $retryAfter = 5 }
        Start-Sleep -Seconds ([int]$retryAfter)
        continue
      }
      throw
    }

    foreach ($r in $page.results) { $all.Add($r) }
    $next = $page.next
  }

  return $all
}

$screens = Get-AllYodeckScreens -Url $StartUrl
Write-Host "Hentet $($screens.Count) skjermer."

# --- Filtrer offline basert på state.online ---
$offline = $screens |
  Where-Object { $_.state -and $_.state.online -eq $false } |
  Select-Object `
    id,
    name,
    @{n="workspace"; e={ $_.workspace.name }},
    @{n="registered"; e={ $_.state.registered }},
    @{n="last_seen"; e={ $_.state.last_seen }},
    @{n="updating"; e={ $_.state.updating }},
    @{n="status_last_updated"; e={ $_.player_status.status_last_updated }},
    last_pushed,
    last_ip_address,
    @{n="wifi"; e={ $_.player_status.wifi_status.connected_wifi_name }},
    @{n="hostname"; e={ $_.player_status.hostname }},
    @{n="software"; e={ $_.player_status.software_version }}

$offline | Sort-Object last_seen | Format-Table -AutoSize

# Valgfritt: CSV
# $offline | Export-Csv -NoTypeInformation -Encoding UTF8 ".\yodeck-offline-screens.csv