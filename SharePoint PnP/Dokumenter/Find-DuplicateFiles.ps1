
# Requires: PnP.PowerShell module
# Install if needed: Install-Module PnP.PowerShell -Scope CurrentUser

param(
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl,

    [Parameter(Mandatory=$true)]
    [string]$LibraryName,

    [Parameter(Mandatory=$true)]
    [string]$OutputCsv
)

# Connect to SharePoint Online
$pfxPassword = ConvertTo-SecureString -String "Chowtime7-Affair-Praising-Premium" -AsPlainText -Force
$kunde = "idohshavbruk"
Connect-PnPOnline -Url "https://$kunde.sharepoint.com" `
    -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" `
    -Tenant "$kunde.onmicrosoft.com" `
    -CertificatePath "C:\Cert\PnPAppCert.pfx" `
    -CertificatePassword $pfxPassword

# Get all files from the specified document library recursively
$files = Get-PnPFolderItem -FolderSiteRelativeUrl $LibraryName -ItemType File -Recursive

Write-Host "Found $($files.Count) files in $LibraryName"

# Group files by Name and Size to find potential duplicates
$potentialGroups = $files | Group-Object -Property Name, Length | Where-Object { $_.Count -gt 1 }

Write-Host "Found $($potentialGroups.Count) potential duplicate groups based on Name and Size"

$hashTable = @{}
$duplicates = @()

foreach ($group in $potentialGroups) {
    foreach ($file in $group.Group) {
        # Download file to temp location
        $tempPath = Join-Path $env:TEMP $file.Name
        Get-PnPFile -ServerRelativeUrl $file.ServerRelativeUrl -Path $env:TEMP -FileName $file.Name -AsFile -Force

        # Compute SHA256 hash
        $hash = Get-FileHash -Path $tempPath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

        # Remove temp file
        Remove-Item $tempPath -Force

        # Check for duplicates by hash
        if ($hashTable.ContainsKey($hash)) {
            $duplicates += [PSCustomObject]@{
                Hash = $hash
                OriginalFile = $hashTable[$hash]
                DuplicateFile = $file.ServerRelativeUrl
                Size = $file.Length
                LastModified = $file.TimeLastModified
            }
        } else {
            $hashTable[$hash] = $file.ServerRelativeUrl
        }
    }
}

# Export confirmed duplicates to CSV
$duplicates | Export-Csv -Path $OutputCsv -NoTypeInformation

Write-Host "Duplicate report saved to $OutputCsv"
