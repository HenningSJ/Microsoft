#Bruk SharePoint Online Management Shell for å kjøre dette skriptet
#Import-Module -Name Microsoft.Online.SharePoint.PowerShell

# Sett Home site og la Viva starte på SharePoint-siden (desktop)
Connect-SPOService -Url https://itpartnerno-admin.sharepoint.com

#Get-SPOHomeSite

Set-SPOHomeSite -HomeSiteUrl https://itpartnerno.sharepoint.com -VivaConnectionsDefaultStart:$true

  