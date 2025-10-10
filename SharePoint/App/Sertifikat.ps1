


# Generer sertifikatet i CurrentUser\My store
$cert = New-SelfSignedCertificate `
    -Subject "CN=Copilot Ready" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -NotAfter (Get-Date).AddYears(2)


    # Sett et sterkt passord for PFX-filen
$pfxPassword = ConvertTo-SecureString -String "Karma-Multitude-Goldmine-Stopwatch4" -AsPlainText -Force





$certname = "Copilot Ready"    ## Replace {certificateName}
$cert = New-SelfSignedCertificate `
    -Subject "CN=$certname" `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -KeyLength 2048 `
    -KeyAlgorithm RSA `
    -HashAlgorithm SHA256

Export-Certificate -Cert $cert -FilePath "C:\Cert\$certname.cer"   ## Specify your preferred location





# Eksporter til PFX
Export-PfxCertificate -Cert $cert -FilePath "C:\Cert\PnPAppCert.pfx" -Password $pfxPassword

Export-Certificate -Cert $cert -FilePath "C:\Cert\PnPAppCert.cer"

#Slette sertifikat
Get-ChildItem -Path "Cert:\CurrentUser\My"
Remove-Item -Path Cert:\CurrentUser\My\{A4900BE277708C953A3101ADEF53AEBFABDDD970} -DeleteKey


#Dele App til annen tenant:
https://login.microsoftonline.com/common/adminconsent?client_id=95f12ea4-41ec-45f0-97d3-f2bda3373b1e