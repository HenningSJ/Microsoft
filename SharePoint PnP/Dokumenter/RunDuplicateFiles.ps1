# Installer PnP.PowerShell hvis du ikke har det
#Install-Module PnP.PowerShell -Scope CurrentUser
# Sjekk installasjonen
#Get-Module PnP.PowerShell -ListAvailable

#Import-Module PnP.PowerShell

Connect-PnPOnline -Interactive

# Kjør skriptet
.\Find-DuplicateFiles.ps1 `
    -SiteUrl "https://ohshavbruk.sharepoint.com/sites/Dokumenter" `
    -LibraryName "Dokumenter" `
    -OutputCsv "C:\Temp\DuplicateReport.csv" `
    #-TenantID "793cd804-7d18-42e3-9d6b-15672e16a4a1" `
    -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" `
    -CertificatePath "C:\Cert\PnP.PowerShell.pfx" `


# Hmm
Connect-PnPOnline -Url "https://ohshavbruk.sharepoint.com/sites/Dokumenter" -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" -Tenant "ohshavnruk.no.onmicrosoft.com" -Interactive

# Exclution policy
#Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#Set-ExecutionPolicy Bypass -Scope Process