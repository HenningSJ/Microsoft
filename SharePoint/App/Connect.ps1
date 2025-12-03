

# Connect med PFX
$pfxPassword = ConvertTo-SecureString -String "Chowtime7-Affair-Praising-Premium" -AsPlainText -Force
$kunde = "idemo2"

Connect-PnPOnline -Url "https://$kunde.sharepoint.com" `
    -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" `
    -Tenant "$kunde.onmicrosoft.com" `
    -CertificatePath "C:\Cert\PnPAppCert.pfx" `
    -CertificatePassword $pfxPassword

793
# Connect med thumbprint
Connect-PnPOnline `
  -Url "https://ohshavbruk.sharepoint.com"`
  -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" `
  -Tenant "ohshavbruk.onmicrosoft.com" `
  -Thumbprint "7877811816E1CB29DBCCAC968DCE94E6E0409710"

# Test tilgang
Get-PnPWeb


#Finne Thumbprint
$pfxPath = "C:\Cert\PnPAppCert.pfx"
Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\CurrentUser\My -Password $pfxPassword


#Koble til MS Graph
Connect-MgGraph -TenantId "256c6ac2-bdec-4852-894d-4995d602734f" -ClientId "95f12ea4-41ec-45f0-97d3-f2bda3373b1e" -Thumbprint "619879343B4F264BF8E23F1B133AC86460F97B0A"


#Dele App til annen tenant:
https://login.microsoftonline.com/common/adminconsent?client_id=a7a5183a-e869-4a62-bed5-9db047261207