
Connect-SPOService -Url https://rafisklaget-admin.sharepoint.com

Set-SPOOrgNewsSite -OrgNewsSiteUrl "https://rafisklaget.sharepoint.com/sites/Nyheter" 
Set-SPOOrgNewsSite -OrgNewsSiteUrl "https://rafisklaget.sharepoint.com" 

Get-SPOOrgNewsSite

#Remove-SPOOrgNewsSite -OrgNewsSiteUrl "https://itpartnerno.sharepoint.com/sites/nyheter"