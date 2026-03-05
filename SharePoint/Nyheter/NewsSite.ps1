
Connect-SPOService -Url https://itpartnerno-admin.sharepoint.com

Set-SPOOrgNewsSite -OrgNewsSiteUrl "https://itpartnerno.sharepoint.com/sites/nyheter"

Get-SPOOrgNewsSite

#Remove-SPOOrgNewsSite -OrgNewsSiteUrl "https://itpartnerno.sharepoint.com/sites/nyheter"