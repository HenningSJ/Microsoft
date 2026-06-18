# Koble til admin-senteret
Connect-SPOService -Url https://dagenborg-admin.sharepoint.com

# Opprett gruppeområde UTEN 365-gruppe (mal STS#3)
New-SPOSite `
    -Url "https://dagenborg.sharepoint.com/sites/Administrasjon" `
    -Owner "admin_serit@dagenborg.no" `
    -Title "Administrasjon" `
    -Template "STS#3" `
    -StorageQuota 204800