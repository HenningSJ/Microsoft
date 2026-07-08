#Install-Module PnP.PowerShell

#$SiteURL = "https://dagenbord.sharepoint.com/sites/felles"
$LibraryName = "Delte Dokumenter" 

#Connect-PnPOnline -Url $SiteURL -Interactive

# Get the library and all items with unique permissions
$List = Get-PnPList -Identity $LibraryName
$Items = Get-PnPListItem -List $List -PageSize 500 | Where-Object {$_.FileSystemObjectType -eq "Folder" -and $_.HasUniqueRoleAssignments -eq $True}

foreach ($Item in $Items) {
    # Reset role inheritance
    $Item.ResetRoleInheritance()
    Write-Host "Restored inheritance for: $($Item['FileLeafRef'])" -ForegroundColor Green
}
