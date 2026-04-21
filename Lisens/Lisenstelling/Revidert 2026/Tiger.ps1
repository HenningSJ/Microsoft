<#
=============================================================================================
Name:           TigerEiendom.ps1
Description:    Lisensrapport for Tiger Eiendomskompetanse AS / Tromsø Næringsmegling AS
Revidert av:    Henning Smedvik Johnsen
Basert på:      felles funksjoner.ps1
=============================================================================================
#>

#region Import felles funksjoner
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Konfigurasjon

$Config = @{
    TenantId       = "a0ab6b13-710d-4775-b475-e8cc278db94d"
    ClientId       = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"

    CustomerName   = "Tiger Eiendom"

    BaseFileName   = "Lisenser-TigerEiendom"
    TempDirectory  = "C:\temp\Lisenstelling"
    OutputDirectory= "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\TigerEiendom"

    ExportCSV        = $true
    IncludeUserLists = $true

    # Eksplisitte Oslo‑brukere
    OsloUsers = @(
        "bes@tigereiendom.no",
        "ec@tigereiendom.no",
        "mf@tigereiendom.no",
        "gb@tigereiendom.no"
    )

    Organizations = @(
        @{ Name = "Tiger Eiendomskompetanse AS (Oslo)"; Match = { $_.UserPrincipalName -in  $Config.OsloUsers } }
        @{ Name = "Tromsø Næringsmegling AS";           Match = { $_.UserPrincipalName -notin $Config.OsloUsers } }
    )

    Licenses = @(
        @{ DisplayName = "Microsoft 365 Business Premium"; PartNumbers = @("SPB") }
        @{ DisplayName = "Exchange Online Plan 2";         PartNumbers = @("EXCHANGEENTERPRISE") }
        @{ DisplayName = "Microsoft 365 Copilot";          PartNumbers = @("Microsoft_365_Copilot") }
    )
}

#endregion

#region Start rapport

Write-Host "=== Starter lisensrapport – $($Config.CustomerName) ===" -ForegroundColor Cyan

if (-not (Connect-M365GraphAPI `
    -TenantId $Config.TenantId `
    -ClientId $Config.ClientId `
    -CertThumbprint $Config.CertThumbprint)) {
    throw "Klarte ikke å koble til Microsoft Graph"
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"

New-Item -ItemType Directory -Path $Config.TempDirectory  -Force | Out-Null
New-Item -ItemType Directory -Path $Config.OutputDirectory -Force | Out-Null

$txtPath = Join-Path $Config.TempDirectory "$($Config.BaseFileName)-$timestamp.txt"
$csvPath = Join-Path $Config.TempDirectory "$($Config.BaseFileName)-$timestamp.csv"

# Header
"Lisensrapport – $($Config.CustomerName)" | Out-File $txtPath -Encoding UTF8
"Generert: $(Get-Date)"                  | Out-File -Append $txtPath -Encoding UTF8
"-----------------------------------------------------------" | Out-File -Append $txtPath -Encoding UTF8
"" | Out-File -Append $txtPath

# Hent tenant‑data én gang
$AllSkus  = Get-AllTenantSKUs
$AllUsers = Get-AllUsers

$csvRows = @()

foreach ($lic in $Config.Licenses) {

    $sum = Get-SkuSummary `
        -DisplayName $lic.DisplayName `
        -PartNumbers $lic.PartNumbers `
        -AllSkus $AllSkus

    Write-LicenseTotals -Summary $sum -OutputPath $txtPath

    if ([string]::IsNullOrWhiteSpace($sum.SkuId)) {
        $users = @()
    }
    else {
        $users = Get-LicenseUsers -Users $AllUsers -SkuId $sum.SkuId
    }

    $counts = Get-OrganizationCounts `
        -Users $users `
        -Organizations $Config.Organizations

    Write-PerCompanySection `
        -Title $sum.DisplayName `
        -Counts $counts `
        -OutputPath $txtPath

    foreach ($org in $counts.Keys) {
        $csvRows += [PSCustomObject]@{
            ReportDate    = Get-Date
            License       = $sum.DisplayName
            PartNumber   = $sum.PartNumber
            Organization = $org
            Count         = $counts[$org]
            Enabled       = $sum.Enabled
            Consumed      = $sum.Consumed
            Unassigned    = $sum.Unassigned
        }
    }

    if ($Config.IncludeUserLists -and $users.Count -gt 0) {
        Write-UserList -Title $sum.DisplayName -Users $users -OutputPath $txtPath
        Write-DiscrepancyCheck -Title $sum.DisplayName -Summary $sum -Users $users -OutputPath $txtPath
        Write-NonClassifiedList -Title $sum.DisplayName -Users $users -Organizations $Config.Organizations -OutputPath $txtPath
    }

    "" | Out-File -Append $txtPath
}

# CSV‑eksport
if ($Config.ExportCSV -and $csvRows.Count -gt 0) {
    $csvRows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force
}

# --- Robust kopiering til OneDrive ---
Start-Sleep -Milliseconds 200

$destTxt = Join-Path $Config.OutputDirectory (Split-Path $txtPath -Leaf)
$destCsv = Join-Path $Config.OutputDirectory (Split-Path $csvPath -Leaf)

if (Test-Path $txtPath) {
    Copy-Item $txtPath $destTxt -Force -ErrorAction Stop
    Remove-Item $txtPath -Force
}

if (Test-Path $csvPath) {
    Copy-Item $csvPath $destCsv -Force -ErrorAction Stop
    Remove-Item $csvPath -Force
}

Write-Host "✓ Rapport ferdig – Tiger Eiendom" -ForegroundColor Green
#endregion
