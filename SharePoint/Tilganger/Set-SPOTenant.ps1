#Connect to Tenant Admin
Connect-SPOService -Url "https://itpartnerno-admin.sharepoint.com"
 

Get-SPOTenant | Select-Object ExternalUserExpireInDays, ExternalUserExpirationRequired


#Set External User Expiration Settings
Set-SPOTenant -ExternalUserExpirationRequired $True -ExternalUserExpireInDays 90



#Set External User Expiration Settings for the site
Set-SPOSite -Identity SiteURL -OverrideTenantExternalUserExpirationPolicy $False -ExternalUserExpirationInDays 90