#Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Import-Module Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://thearctictravelcompany-admin.sharepoint.com

Get-SPOTenant | Select SharingCapability
Get-SPOSite -Identity https://thearctictravelcompany.sharepoint.com/sites/SK-Mediabank | Select SharingCapability