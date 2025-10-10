
#Config Variables
$SiteURL = "https://lufttransport.sharepoint.com/sites/OperativePersonnel"
$UserAccount= "Thomas.Asheim@lufttransport.no"
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
  
#Get the Default Owners Group of the site
$OwnersGroup = Get-PnPGroup  -AssociatedOwnerGroup
  
#SharePoint Online pnp powershell to add site owner
Add-PnPGroupMember -LoginName $UserAccount -Identity $OwnersGroup


