
#Office Template
Add-SPOOrgAssetsLibrary -LibraryUrl "https://itpartnerno.sharepoint.com/sites/OrgAssetsLibrary/OfficeTemplate" -OrgAssetType OfficeTemplateLibrary

#Font
Add-SPOOrgAssetsLibrary -LibraryUrl "https://itpartnerno.sharepoint.com/sites/OrgAssetsLibrary/OfficeFont" -OrgAssetType OfficeFontLibrary -CdnType Public
Set-SPOCustomFontCatalog -FontFolder "C:\Inter" -LibraryUrl https://itpartnerno.sharepoint.com/sites/OrgAssetsLibrary/OfficeFont

#Sjekk
Get-SPOOrgAssetsLibrary
Get-SPOTenantCdnOrigins -CdnType Private   

#Fjern
Remove-SPOOrgAssetsLibrary -LibraryUrl "https://itpartnerno.sharepoint.com/sites/brandcenter"

#Bilder
Add-SPOOrgAssetsLibrary -LibraryURL "https://itpartnerno.sharepoint.com/sites/OrgAssetsLibrary/" -OrgAssetType ImageDocumentLibrary -CopilotSearchable $True


Add-SPOOrgAssetsLibrary -LibraryUrl "https://rafisklaget.sharepoint.com/sites/OrgAssetsLibrary/OfficeTemplate" -OrgAssetType OfficeTemplateLibrary
Add-SPOOrgAssetsLibrary -LibraryUrl "https://rafisklaget.sharepoint.com/sites/OrgAssetsLibrary/OfficeFont" -OrgAssetType OfficeFontLibrary -CdnType Public
Set-SPOCustomFontCatalog -FontFolder "C:\OpenSans" -LibraryUrl https://rafisklaget.sharepoint.com/sites/OrgAssetsLibrary/OfficeFont 
Remove-SPOOrgAssetsLibrary -LibraryUrl "https://itpartnerno.sharepoint.com/sites/Dokumentsky/NR Merkevare"

