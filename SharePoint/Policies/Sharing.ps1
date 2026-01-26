#Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://thearctictravelcompany-admin.sharepoint.com

Get-SPOTenant | Select-Object SharingCapability
Get-SPOSite -Identity https://thearctictravelcompany.sharepoint.com/sites/SK-Mediabank | Select-Object SharingCapability