#region Felles funksjonsbibliotek for M365 lisensrapportering

function Connect-M365GraphAPI {
    param(
        [Parameter(Mandatory=$true)][string]$TenantId,
        [Parameter(Mandatory=$true)][string]$ClientId,
        [Parameter(Mandatory=$true)][string]$CertThumbprint
    )
    try {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Kobler til Microsoft Graph API..." -ForegroundColor Cyan
        Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertThumbprint -NoWelcome -ErrorAction Stop
        Write-Host "✓ Tilkoblet Microsoft Graph API" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Feil ved tilkobling til Microsoft Graph: $_"
        return $false
    }
}


function Get-AllUsers {
    [CmdletBinding()]
    param(
        [string]$Property = "DisplayName,UserPrincipalName,AssignedLicenses,Department,CompanyName,OfficeLocation"
    )
    try {
        return Get-MgUser -All -Property $Property -ErrorAction Stop
    }
    catch {
        Write-Error "Kunne ikke hente brukere fra Graph: $($_.Exception.Message)"
        return @()
    }
}


function Get-AllTenantSKUs {
    <#
      Returnerer hashtable keyed by SkuId (GUID som string)
      Verdi: SkuId, SkuPartNumber, FriendlyName, TotalLicenses, ConsumedLicenses, AvailableLicenses
    #>
    [CmdletBinding()]
    param()

    try {
        Write-Host "`nHenter alle tilgjengelige SKUer fra tenant..." -ForegroundColor Cyan
        $skus = Get-MgSubscribedSku -All -ErrorAction Stop

        $ht = @{}
        foreach ($sku in $skus) {
            $enabled   = [int]$sku.PrepaidUnits.Enabled
            $consumed  = [int]$sku.ConsumedUnits
            $available = [math]::Max(0, ($enabled - $consumed))

            $obj = [PSCustomObject]@{
                SkuId             = [string]$sku.SkuId
                SkuPartNumber     = [string]$sku.SkuPartNumber
                FriendlyName      = Get-FriendlyLicenseName -SkuPartNumber $sku.SkuPartNumber
                TotalLicenses     = $enabled
                ConsumedLicenses  = $consumed
                AvailableLicenses = $available
            }

            $ht[[string]$sku.SkuId] = $obj
        }

        Write-Host "✓ Hentet $($ht.Count) SKU-typer" -ForegroundColor Green
        return $ht
    }
    catch {
        Write-Error "Feil ved henting av SKUer: $($_.Exception.Message)"
        return @{}
    }
}


# ------------------------------
# SKU / PartNumber helpers
# ----------------------------

function Get-FriendlyLicenseName {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$SkuPartNumber)

    $map = @{
        'SPB'                       = 'Microsoft 365 Business Premium'
        'O365_BUSINESS_PREMIUM'     = 'Microsoft 365 Business Standard'
        'O365_BUSINESS_ESSENTIALS'  = 'Microsoft 365 Business Basic'
        'EXCHANGESTANDARD'          = 'Exchange Online Plan 1'
        'EXCHANGEENTERPRISE'        = 'Exchange Online Plan 2'
        'EXCHANGEDESKLESS'          = 'Exchange Online Kiosk'
        'POWER_BI_PRO'              = 'Power BI Pro'
        'PBI_PREMIUM_PER_USER'      = 'Power BI Premium (Per User)'
        'POWER_BI_PREMIUM_PER_USER' = 'Power BI Premium (Per User)'
        'FLOW_PER_USER'             = 'Power Automate Per user'
        'FLOW_PER_USER_P2'          = 'Power Automate Per user'
        'FLOW_FREE'                 = 'Power Automate Free'
        'POWERAPPS_PER_USER'        = 'Power Apps Premium'
        'POWERAUTOMATE_ATTENDED_RPA' = 'Power Automate Premium'
        'VISIOCLIENT'               = 'Visio Plan 2'
        'Microsoft_365_Copilot'      = 'Microsoft 365 Copilot'
        'SHAREPOINTSTORAGE'          = 'SharePoint Extra Storage (GB)'
        'Microsoft_Teams_Rooms_Pro'  = 'Microsoft Teams Rooms Pro'
        'MTR_PRO'                    = 'Microsoft Teams Rooms Pro'
        'M365_F1'                    = 'Microsoft 365 F1'
        'M365_F1_COMM'               = 'Microsoft 365 F1'
        'SPE_F1'                     = 'Microsoft 365 F1'
        'Microsoft_365_F1'           = 'Microsoft 365 F1'
    }

    if ($map.ContainsKey($SkuPartNumber)) { return $map[$SkuPartNumber] }
    return $SkuPartNumber
}


function Resolve-SkuByPartNumbers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$PartNumbers,
        [Parameter(Mandatory)][hashtable]$AllSkus
    )

    foreach ($pn in $PartNumbers) {
        $hit = $AllSkus.Values | Where-Object { $_.SkuPartNumber -eq $pn } | Select-Object -First 1
        if ($hit) { return $hit }
    }
    return $null
}


function Get-SkuSummary {
    <#
      Returnerer: DisplayName, PartNumber, SkuId, Enabled, Consumed, Unassigned
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][array]$PartNumbers,
        [Parameter(Mandatory)][hashtable]$AllSkus
    )

    $sku = Resolve-SkuByPartNumbers -PartNumbers $PartNumbers -AllSkus $AllSkus

    if (-not $sku) {
        return [PSCustomObject]@{
            DisplayName = $DisplayName
            PartNumber  = ($PartNumbers -join "|")
            SkuId       = $null
            Enabled     = 0
            Consumed    = 0
            Unassigned  = 0
        }
    }

    $enabled    = [int]$sku.TotalLicenses
    $consumed   = [int]$sku.ConsumedLicenses
    $unassigned = [math]::Max(0, ($enabled - $consumed))

    return [PSCustomObject]@{
        DisplayName = $DisplayName
        PartNumber  = $sku.SkuPartNumber
        SkuId       = $sku.SkuId
        Enabled     = $enabled
        Consumed    = $consumed
        Unassigned  = $unassigned
    }
}


# ------------------------------
# Brukere med gitt SKU
# ------------------------------

function Get-LicenseUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Users,
        [Parameter()][string]$SkuId
    )

    if ([string]::IsNullOrWhiteSpace($SkuId)) { 
        return @() 
    }

    $Users | Where-Object {
        $_.AssignedLicenses -and ($_.AssignedLicenses.SkuId -contains $SkuId)
    }
}


function Get-LicenseCountByDepartment {
    param(
        [Parameter(Mandatory=$true)][string]$SkuId,
        [Parameter(Mandatory=$true)][array]$Companies
    )
    $results = @{}
    try {
        $users = Get-MgUser -All -Property "UserPrincipalName,AssignedLicenses,Department" -ErrorAction Stop
        foreach ($company in $Companies) {
            $filtered = $users | Where-Object {
                $_.AssignedLicenses.SkuId -contains $SkuId -and
                $_.Department -eq $company.DepartmentFilter
            }
            $results[$company.Name] = @($filtered).Count
        }
    } catch {
        Write-Warning "Feil ved telling for SKU $SkuId : $_"
        foreach ($company in $Companies) {
            $results[$company.Name] = 0
        }
    }
    return $results
}

function Get-LicenseCountByOfficeLocation {
    param(
        [Parameter(Mandatory=$true)][string]$SkuId,
        [Parameter(Mandatory=$true)][string]$DepartmentName,
        [Parameter(Mandatory=$true)][array]$Locations,
        [array]$ExcludeUserPrincipals = @(),
        [hashtable]$IncludeAlternate = @{}
    )
    $results = @{}
    try {
        $users = Get-MgUser -All -Property "UserPrincipalName,AssignedLicenses,Department,OfficeLocation" -ErrorAction Stop
        foreach ($location in $Locations) {
            $altNames = @($location.LocationFilter)
            if ($IncludeAlternate.ContainsKey($location.Name)) {
                $altNames += $IncludeAlternate[$location.Name]
            }
            $filtered = $users | Where-Object {
                $_.AssignedLicenses.SkuId -contains $SkuId -and
                $_.Department -eq $DepartmentName -and
                $altNames -contains $_.OfficeLocation -and
                $_.UserPrincipalName -notin $ExcludeUserPrincipals
            }
            $results[$location.Name] = @($filtered).Count
        }
    } catch {
        Write-Warning "Feil ved telling for lokasjoner, SKU $SkuId : $_"
        foreach ($location in $Locations) {
            $results[$location.Name] = 0
        }
    }
    return $results
}

function Get-LicenseUsersPerCompany {
    param(
        [Parameter(Mandatory)]
        [string]$SkuId,

        [Parameter(Mandatory)]
        [array]$Companies,

        [ValidateSet("Domain")]
        [string]$FilterType = "Domain"
    )

    $result = @{}

    try {
        # Hent alle brukere ÉN gang (viktig for ytelse og Graph-begrensninger)
        $users = Get-MgUser -All `
            -Property "UserPrincipalName,AssignedLicenses" `
            -ErrorAction Stop
    }
    catch {
        Write-Warning "Kunne ikke hente brukere: $_"
        return $null
    }

    foreach ($company in $Companies) {
        $matchedUsers = $users | Where-Object {
            $_.AssignedLicenses.SkuId -contains $SkuId -and
            $_.UserPrincipalName -like $company.Filter
        }

        $result[$company.Name] = @($matchedUsers).Count
    }

    return $result
}


function Get-AdministrationLicenseCount {
    param(
        [string]$SkuId,
        [array]$AdminUsers
    )
    try {
        $users = Get-MgUser -All -Property "UserPrincipalName,AssignedLicenses" -ErrorAction Stop
        $filtered = $users | Where-Object {
            $_.UserPrincipalName -in $AdminUsers -and
            $_.AssignedLicenses.SkuId -contains $SkuId
        }
        return @($filtered).Count
    } catch {
        Write-Warning "Feil ved telling av admin-brukere: $_"
        return 0
    }
}


# ------------------------------
# NTC audit: Count / Non-classified
# Organizations: @{Name="NTC"; Match={ $_.Department -eq "NTC" } }
# ------------------------------

function Get-OrganizationCounts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Users,
        [Parameter(Mandatory)][array]$Organizations
    )

    $counts = @{}

    # ✅ Kritisk: tåler tom brukerliste
    if (-not $Users -or $Users.Count -eq 0) {
        foreach ($org in $Organizations) {
            $counts[$org.Name] = 0
        }
        return $counts
    }

    foreach ($org in $Organizations) {
        $counts[$org.Name] = ($Users | Where-Object $org.Match).Count
    }

    return $counts
}


function Get-NonClassifiedUsers {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][array]$Users,
        [Parameter(Mandatory)][array]$Organizations
    )

    $Users | Where-Object {
        foreach ($org in $Organizations) {
            if (& $org.Match $_) { return $false }
        }
        $true
    }
}


# ------------------------------
# Skriving til TXT (audit og enkel rapport)
# ------------------------------
function Write-LicenseTotals {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$Summary,
        [Parameter(Mandatory)][string]$OutputPath
    )

    " $($Summary.DisplayName) = Kunde har totalt $($Summary.Enabled) lisenser"         | Out-File -Append $OutputPath -Encoding UTF8
    " $($Summary.DisplayName) = Kunde har $($Summary.Unassigned) utildelte lisenser"  | Out-File -Append $OutputPath -Encoding UTF8
    "" | Out-File -Append $OutputPath -Encoding UTF8
}

function Write-PerCompanySection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][hashtable]$Counts,
        [Parameter(Mandatory)][string]$OutputPath
    )

    $Title | Out-File -Append $OutputPath -Encoding UTF8
    foreach ($k in $Counts.Keys) {
        "$($k): $($Counts[$k])" | Out-File -Append $OutputPath -Encoding UTF8
    }
    "" | Out-File -Append $OutputPath -Encoding UTF8
}

function Write-UserList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][array]$Users,
        [Parameter(Mandatory)][string]$OutputPath
    )

    "OVERSIKT OVER BRUKERE MED $Title LISENS" | Out-File -Append $OutputPath -Encoding UTF8
    "***************************************************************" | Out-File -Append $OutputPath -Encoding UTF8

    if (-not $Users -or $Users.Count -eq 0) {
        "(Ingen)" | Out-File -Append $OutputPath -Encoding UTF8
    }
    else {
        $Users | Select-Object DisplayName, UserPrincipalName |
            Sort-Object DisplayName |
            Format-Table -AutoSize | Out-String |
            Out-File -Append $OutputPath -Encoding UTF8
    }

    "" | Out-File -Append $OutputPath -Encoding UTF8
    "-----------------------------------------------------------" | Out-File -Append $OutputPath -Encoding UTF8
    "" | Out-File -Append $OutputPath -Encoding UTF8
}

function Write-DiscrepancyCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][pscustomobject]$Summary,
        [Parameter(Mandatory)][array]$Users,
        [Parameter(Mandatory)][string]$OutputPath
    )

    $enabled    = $Summary.Enabled
    $consumed   = $Summary.Consumed
    $unassigned = $Summary.Unassigned
    $countUsers = ($Users | Measure-Object).Count

    "[$Title] Kontroll:"                             | Out-File -Append $OutputPath -Encoding UTF8
    "Kjøpt (Enabled):          $enabled"             | Out-File -Append $OutputPath -Encoding UTF8
    "Tildelt (Consumed):       $consumed"            | Out-File -Append $OutputPath -Encoding UTF8
    "Tildelt (brukerliste):    $countUsers"          | Out-File -Append $OutputPath -Encoding UTF8
    "Utildelte (beregnet):     $unassigned"          | Out-File -Append $OutputPath -Encoding UTF8

    $delta = $consumed - $countUsers
    if ($delta -ne 0) {
        "Avvik: Consumed - brukerliste = $delta (sjekk ressurskontoer/filtre/Department/CompanyName)" |
            Out-File -Append $OutputPath -Encoding UTF8
    }
    else {
        "Avvik: Ingen" | Out-File -Append $OutputPath -Encoding UTF8
    }

    "" | Out-File -Append $OutputPath -Encoding UTF8
}

function Write-NonClassifiedList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][array]$Users,
        [Parameter(Mandatory)][array]$Organizations,
        [Parameter(Mandatory)][string]$OutputPath
    )

    $non = Get-NonClassifiedUsers -Users $Users -Organizations $Organizations

    "[$Title] Brukere uten klassifisering (Department/CompanyName):" | Out-File -Append $OutputPath -Encoding UTF8
    if (-not $non -or $non.Count -eq 0) {
        "(Ingen)" | Out-File -Append $OutputPath -Encoding UTF8
    }
    else {
        $non | Select-Object DisplayName, UserPrincipalName, Department, CompanyName |
            Sort-Object DisplayName |
            Format-Table -AutoSize | Out-String |
            Out-File -Append $OutputPath -Encoding UTF8
    }

    "" | Out-File -Append $OutputPath -Encoding UTF8
}


function Export-ReportToCSV {
    param(
        [Parameter(Mandatory=$true)][array]$ReportData,
        [Parameter(Mandatory=$true)][string]$OutputPath
    )
    try {
        $ReportData | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8 -Force -ErrorAction Stop
        Write-Host "✓ CSV-rapport lagret: $OutputPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Feil ved eksport til CSV: $_"
        return $false
    }
}

function Export-ReportToText {
    param(
        [Parameter(Mandatory=$true)][array]$ReportData,
        [Parameter(Mandatory=$true)][string]$OutputPath,
        [Parameter(Mandatory=$true)][string]$CustomerName
    )
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $output = @()
        $output += "=" * 80
        $output += "MICROSOFT 365 LISENSRAPPORT - $($CustomerName.ToUpper())"
        $output += "Generert: $timestamp"
        $output += "=" * 80
        $output += ""
        $grouped = $ReportData | Group-Object -Property LicenseType
        foreach ($group in $grouped) {
            $first = $group.Group[0]
            $output += "-" * 80
            $output += "LISENSTYPE: $($group.Name)"
            $output += "-" * 80
            $output += "SKU PartNumber: $($first.SkuPartNumber)"
            $output += ""
            $output += "Totalt i tenant:  $($first.TotalLicenses)"
            $output += "Tildelt totalt:   $($first.ConsumedLicenses)"
            $output += "Ledig totalt:     $($first.AvailableLicenses)"
            $output += ""
            $output += "FORDELING PER SELSKAP:"
            $output += "-" * 80
            foreach ($row in $group.Group) {
                $output += "  {0,-40} : {1,5}" -f $row.CompanyName, $row.LicenseCount
            }
            $output += ""
        }
        $output += "=" * 80
        $output += "Slutt på rapport"
        $output += "=" * 80
        $output | Out-File -FilePath $OutputPath -Encoding UTF8 -Force
        Write-Host "✓ TXT-rapport lagret: $OutputPath" -ForegroundColor Green
        return $true
    } catch {
        Write-Error "Feil ved eksport til TXT: $_"
        return $false
    }
}

#endregion