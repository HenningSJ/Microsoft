
$pfxPassword = ConvertTo-SecureString -String "Karma-Multitude-Goldmine-Stopwatch4" -AsPlainText -Force
$kunde = "idemo2"

Connect-PnPOnline -Url "https://$kunde.sharepoint.com" `
    -ClientId "95f12ea4-41ec-45f0-97d3-f2bda3373b1e" `
    -Tenant "$kunde.onmicrosoft.com" `
    -CertificatePath "C:\Cert\PnPAppCert.pfx" `
    -CertificatePassword $pfxPassword

# Test tilgang
Get-PnPWeb


#Finne Thumbprint
$pfxPath = "C:\Cert\PnPAppCert.pfx"
Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\CurrentUser\My -Password $pfxPassword


#Koble til MS Graph
Connect-MgGraph -TenantId "256c6ac2-bdec-4852-894d-4995d602734f" -ClientId "95f12ea4-41ec-45f0-97d3-f2bda3373b1e" -Thumbprint "619879343B4F264BF8E23F1B133AC86460F97B0A"


#Dele App til annen tenant:
https://login.microsoftonline.com/common/adminconsent?client_id=95f12ea4-41ec-45f0-97d3-f2bda3373b1e