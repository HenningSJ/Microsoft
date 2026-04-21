#Dette genererer et selvsignert sertifikat som kan brukes for å autentisere mot Microsoft Graph API. 
#Det er viktig å merke seg at selvsignerte sertifikater ikke er like sikre som sertifikater utstedt av en betrodd sertifikatutsteder, og bør kun brukes for testing eller i utviklingsmiljøer.

#Lag sertifikatet lokalt
$cert = New-SelfSignedCertificate `
    -Subject "CN=Lisenstelling-Henning" `
    -KeySpec Signature `
    -KeyExportPolicy Exportable `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -NotAfter (Get-Date).AddYears(2)

$cert.Thumbprint
#C3AAA19174488E257748BF732523B3534841865D


#Eksporter public key
Export-Certificate `
    -Cert "Cert:\CurrentUser\My\$($cert.Thumbprint)" `
    -FilePath "C:\Temp\Lisenstelling-Henning.cer"


#Finn applikasjonen i App registrations > Certificates & secrets > Upload certificate > Velg .cer-filen > Save