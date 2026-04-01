<# ==============================================
Name:           Office 365 license reporting tool
Description:    Lisensoversikt for MSK/Vacumkjempen med korrekt telling
Forfatter:      (opprinnelig Kim Skog) – revidert
Dato:           Oppdatert
================================================ #>

#Koble fra eksisterende Microsoft Graph API
Disconnect-MgGraph

#Koble til Microsoft Graph API
$TenantId = "4b6097f0-48ba-46d9-be7f-6b4db0db5008"
$ClientId = "7de25f71-0ade-47d0-9f1c-3717d17ab32d"
$CertThumbprint = "C3AAA19174488E257748BF732523B3534841865D"

Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertThumbprint


# Filbane
$FilePath = "C:\temp\O365Users-Maskinentreprenør Stig Kristiansen.txt"
Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue
$Today = Get-Date

"Oversikt over O365 lisensene til Maskinentreprenør Stig Kristiansen / Vacumkjempen pr $Today" | Out-File -FilePath $FilePath -Encoding UTF8
"-----------------------------------------------------------" | Out-File -FilePath $FilePath -Append -Encoding UTF8
"" | Out-File -FilePath $FilePath -Append -Encoding ASCII

# Hent alle SKU-er i tenant
$skus = Get-MgSubscribedSku

# Finn SKU-er etter SkuPartNumber (unngå hardkodede GUID-er)
$sku_bp        = $skus | Where-Object SkuPartNumber -eq 'SPB'                   # Microsoft 365 Business Premium
$sku_proj      = $skus | Where-Object SkuPartNumber -eq 'PROJECTPROFESSIONAL'   # Project Plan 3
$sku_visio2    = $skus | Where-Object SkuPartNumber -eq 'VISIOCLIENT'           # Visio Plan 2
$sku_copilot   = $skus | Where-Object SkuPartNumber -eq 'Microsoft_365_Copilot' # M365 Copilot

# Funksjon for å skrive totaler + ledige korrekt
function Format-SkuLine($sku, $label) {
    if (-not $sku) {
        return @(
            "$label = (SKU ikke funnet i tenant)",
            "$label = (utildelte: n/a)",
            ""
        )
    }
    $totalEnabled = $sku.PrepaidUnits.Enabled
    $consumed     = $sku.ConsumedUnits
    $free         = $totalEnabled - $consumed
    return @(
        "$label = Kunde har totalt $totalEnabled lisenser",
        "$label = Kunde har $free utildelte lisenser",
        ""
    )
}

(Format-SkuLine $sku_bp      "Microsoft 365 Business Premium") | Out-File -Append -FilePath $FilePath -Encoding UTF8
(Format-SkuLine $sku_proj    "Planner and Project Plan 3")     | Out-File -Append -FilePath $FilePath -Encoding UTF8
(Format-SkuLine $sku_visio2  "Visio Plan 2")                   | Out-File -Append -FilePath $FilePath -Encoding UTF8
(Format-SkuLine $sku_copilot "Microsoft 365 Copilot")          | Out-File -Append -FilePath $FilePath -Encoding UTF8

"-----------------------------------------------------------" | Out-File -FilePath $FilePath -Append -Encoding UTF8
"" | Out-File -FilePath $FilePath -Append -Encoding ASCII

# Domener
$mskDomainPattern = '@stig\-kristiansen\.no$'  # MSK
$vacDomainPattern = '@vacumkjempen\.no$'       # Vacumkjempen

# Ekstra brukere som skal telles under MSK selv om domenet ikke matcher (eks. seritadmin)
$mskExtraUpns = @(
    'seritadmin@stigkristiansen.onmicrosoft.com'
)

# Hent alle brukere én gang
$allUsers = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AssignedLicenses"

# Hjelpefunksjon: telle brukere per «kunde»
function Count-Users-WithSku {
    param(
        [Parameter(Mandatory=$true)] [array] $users,
        [Parameter(Mandatory=$true)] [Guid]  $skuId,
        [Parameter(Mandatory=$false)] [string] $domainRegex,
        [Parameter(Mandatory=$false)] [string[]] $extraUpns
    )

    # 1) Start med de som matcher domenet (hvis angitt)
    $domainMatched = if ($domainRegex) {
        $users | Where-Object { $_.UserPrincipalName -match $domainRegex }
    } else {
        @() # tomt
    }

    # 2) Legg til eksplisitte ekstra UPN-er (uavhengig av domene)
    $extras = @()
    if ($extraUpns) {
        $extraSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $extraUpns | ForEach-Object { [void]$extraSet.Add($_) }
        $extras = $users | Where-Object { $extraSet.Contains($_.UserPrincipalName) }
    }

    # 3) Slå sammen og fjern duplikater (kan oppstå hvis ekstraUPN også matcher domene)
    $combined = @()
    $seen = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($u in ($domainMatched + $extras)) {
        if ($null -ne $u -and -not $seen.Contains($u.Id)) {
            $combined += $u
            [void]$seen.Add($u.Id)
        }
    }

    # 4) Tell de som faktisk har lisensen
    $licensed = $combined | Where-Object { $_.AssignedLicenses.SkuId -contains $skuId }
    return @($licensed).Count
}

# ------------------ Business Premium ------------------
"Microsoft 365 Business Premium" | Out-File -Append -FilePath $FilePath -Encoding UTF8
$bpSkuId = $sku_bp.SkuId
$MSKM365BP = if ($bpSkuId) { Count-Users-WithSku -users $allUsers -skuId $bpSkuId -domainRegex $mskDomainPattern -extraUpns $mskExtraUpns } else { 0 }
$VACM365BP = if ($bpSkuId) { Count-Users-WithSku -users $allUsers -skuId $bpSkuId -domainRegex $vacDomainPattern } else { 0 }
"Maskinentreprenør Stig Kristiansen: $MSKM365BP" | Out-File -Append -FilePath $FilePath -Encoding UTF8
"Vacumkjempen VVS: $VACM365BP"                  | Out-File -Append -FilePath $FilePath -Encoding UTF8
"" | Out-File -Append -FilePath $FilePath -Encoding ASCII

# ------------------ Project Plan 3 ------------------
"Planner and Project Plan 3" | Out-File -Append -FilePath $FilePath -Encoding UTF8
$projSkuId = $sku_proj.SkuId
$MSKPROJ = if ($projSkuId) { Count-Users-WithSku -users $allUsers -skuId $projSkuId -domainRegex $mskDomainPattern -extraUpns $mskExtraUpns } else { 0 }
$VACPROJ = if ($projSkuId) { Count-Users-WithSku -users $allUsers -skuId $projSkuId -domainRegex $vacDomainPattern } else { 0 }
"Maskinentreprenør Stig Kristiansen: $MSKPROJ" | Out-File -Append -FilePath $FilePath -Encoding UTF8
"Vacumkjempen VVS: $VACPROJ"                  | Out-File -Append -FilePath $FilePath -Encoding UTF8
"" | Out-File -Append -FilePath $FilePath -Encoding ASCII

# ------------------ Visio Plan 2 ------------------
"Visio Plan 2" | Out-File -Append -FilePath $FilePath -Encoding UTF8
$vis2SkuId = $sku_visio2.SkuId
$MSKVIS2 = if ($vis2SkuId) { Count-Users-WithSku -users $allUsers -skuId $vis2SkuId -domainRegex $mskDomainPattern -extraUpns $mskExtraUpns } else { 0 }
$VACVIS2 = if ($vis2SkuId) { Count-Users-WithSku -users $allUsers -skuId $vis2SkuId -domainRegex $vacDomainPattern } else { 0 }
"Maskinentreprenør Stig Kristiansen: $MSKVIS2" | Out-File -Append -FilePath $FilePath -Encoding UTF8
"Vacumkjempen VVS: $VACVIS2"                  | Out-File -Append -FilePath $FilePath -Encoding UTF8
"" | Out-File -Append -FilePath $FilePath -Encoding ASCII

# ------------------ Microsoft 365 Copilot ------------------
"Microsoft 365 Copilot" | Out-File -Append -FilePath $FilePath -Encoding UTF8
$copilotSkuId = $sku_copilot.SkuId
$MSKCopilot = if ($copilotSkuId) { Count-Users-WithSku -users $allUsers -skuId $copilotSkuId -domainRegex $mskDomainPattern -extraUpns $mskExtraUpns } else { 0 }
$VACCopilot = if ($copilotSkuId) { Count-Users-WithSku -users $allUsers -skuId $copilotSkuId -domainRegex $vacDomainPattern } else { 0 }
"Maskinentreprenør Stig Kristiansen: $MSKCopilot" | Out-File -Append -FilePath $FilePath -Encoding UTF8
"Vacumkjempen VVS: $VACCopilot"                  | Out-File -Append -FilePath $FilePath -Encoding UTF8
"" | Out-File -Append -FilePath $FilePath -Encoding ASCII