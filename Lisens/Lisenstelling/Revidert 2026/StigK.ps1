
#region Import felles funksjoner
. "C:\VS Code\Microsoft\Lisens\Lisenstelling\Revidert 2026\funksjoner.ps1"
#endregion

#region Konfigurasjon

$Config = @{
    TenantId       = "4b6097f0-48ba-46d9-be7f-6b4db0db5008"
    ClientId       = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
    CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"

    CustomerName   = "Maskinentreprenør Stig Kristiansen"

    BaseFileName   = "Lisenser-StigKristiansen"
    TempDirectory  = "C:\temp\Lisenstelling"
    OutputDirectory= "C:\Users\Henning\OneDrive - IT Partner Tromsø AS\Lisenstelling\StigKristiansen"

    ExportCSV       = $true
    IncludeUserLists= $true

    # Domenebasert organisering
    Organizations = @(
        @{ Name = "Maskinentreprenør Stig Kristiansen"; Match = { $_.UserPrincipalName -like "*@stig-kristiansen.no" } }
        @{ Name = "Vacumkjempen VVS";                   Match = { $_.UserPrincipalName -like "*@vacumkjempen.no" } }
    )

    # Lisenser som rapporteres
    Licenses = @(
        @{ DisplayName = "Microsoft 365 Business Premium"; PartNumbers = @("SPB") }
        @{ DisplayName = "Planner and Project Plan 3";     PartNumbers = @("PROJECTPROFESSIONAL") }
        @{ DisplayName = "Visio Plan 2";                   PartNumbers = @("VISIOCLIENT") }
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

New-Item -ItemType Directory -Path $Config.TempDirectory -Force | Out-Null
New-Item -ItemType Directory -Path $Config.OutputDirectory -Force | Out-Null

$txtPath = Join-Path $Config.TempDirectory "$($Config.BaseFileName)-$timestamp.txt"
$csvPath = Join-Path $Config.TempDirectory "$($Config.BaseFileName)-$timestamp.csv"

# Header
"Lisensrapport – $($Config.CustomerName)" | Out-File $txtPath -Encoding UTF8
"Generert: $(Get-Date)"                  | Out-File -Append $txtPath -Encoding UTF8
"-----------------------------------------------------------" | Out-File -Append $txtPath -Encoding UTF8
"" | Out-File -Append $txtPath

# Hent data én gang
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

    $counts = Count-ByOrganization `
        -Users $users `
        -Organizations $Config.Organizations

    Write-PerCompanySection `
        -Title $sum.DisplayName `
        -Counts $counts `
        -OutputPath $txtPath

    foreach ($org in $counts.Keys) {
        $csvRows += [PSCustomObject]@{
            ReportDate   = Get-Date
            License      = $sum.DisplayName
            PartNumber  = $sum.PartNumber
            Organization= $org
            Count        = $counts[$org]
            Enabled      = $sum.Enabled
            Consumed     = $sum.Consumed
            Unassigned   = $sum.Unassigned
        }
    }

    if ($Config.IncludeUserLists -and $users.Count -gt 0) {
        Write-UserList -Title $sum.DisplayName -Users $users -OutputPath $txtPath
        Write-DiscrepancyCheck -Title $sum.DisplayName -Summary $sum -Users $users -OutputPath $txtPath
    }
}

# Eksport
$csvRows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -Force

Move-Item $txtPath $Config.OutputDirectory -Force
Move-Item $csvPath $Config.OutputDirectory -Force

Write-Host "✓ Rapport ferdig" -ForegroundColor Green
#endregion
