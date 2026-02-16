
Connect-SPOService -Url https://<tenant>-admin.sharepoint.com

Set-SPOOrgNewsSite -OrgNewsSiteUrl "https://<tenant>.sharepoint.com/sites/<nyhetsside>"

Get-SPOOrgNewsSite

#Remove-SPOOrgNewsSite -OrgNewsSiteUrl "https://<tenant>.sharepoint.com/sites/<nyhetsside>"