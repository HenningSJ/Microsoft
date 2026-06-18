Connect-PnPOnline -Url https://dagenborg-admin.sharepoint.com -Interactive

New-PnPSite `
    -Type TeamSiteWithoutMicrosoft365Group `
    -Title "Felles" `
    -Url "https://dagenborg.sharepoint.com/sites/Felles"