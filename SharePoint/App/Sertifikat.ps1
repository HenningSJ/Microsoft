Connect-MgGraph -Scopes "Application.ReadWrite.All"
# Finn APP-ID

# Lag et self signed cerftificate
$cert = New-SelfSignedCertificate -Subject "CN=PnP.PowerShell" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature

# Hent thumbprint
$cert.Thumbprint


# Sett et passord for PFX-filen
$PWD = ConvertTo-SecureString -String "Chowtime7-Affair-Praising-Premium" -Force -AsPlainText
# Eksporter til PFX (Både privat og public key. Public må lastes opp separat, og gjøres lenger nede)
Export-PfxCertificate -Cert $cert -FilePath "C:\Cert\PnP.PowerShell" -Password $PWD


# Eksporter til CER (Kun public key)
Export-Certificate -Cert "Cert:\CurrentUser\My\7877811816E1CB29DBCCAC968DCE94E6E0409710" -FilePath "C:\PnP.PowerShell.cer"

#Konverter CER til PFX:
$cert = Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -like "CN=PnP.PowerShell" }
Export-PfxCertificate -Cert $cert -FilePath "C:\Cert\PnP.PowerShell.pfx" -Password (ConvertTo-SecureString "Chowtime7-Affair-Praising-Premid" -AsPlainText -Force)

# Finn sertifikat
Get-ChildItem Cert:\CurrentUser\My | Select Subject, Thumbprint


# Last opp public key fra PFX i Entra App Registration
$cert = Get-Item "Cert:\CurrentUser\My\$($cert.Thumbprint)"
$bytes = $cert.RawData
Add-MgApplicationKey -ApplicationId cd77df5b-5bc6-4e28-92da-61f885fae758 -KeyCredential @{
    Type="AsymmetricX509Cert"; Usage="Verify"; Key=$bytes; DisplayName="PnP.PowerShell.cer"
}


# 8) Verifiser at nøkkelen ligger inne
(Get-MgApplication -ApplicationId $app.Id).KeyCredentials |
  Format-Table DisplayName, KeyId, Type, Usage, EndDateTime


# Slette sertifikat
#Get-ChildItem -Path "Cert:\CurrentUser\My"
#Remove-Item -Path Cert:\CurrentUser\My\{A4900BE277708C953A3101ADEF53AEBFABDDD970} -DeleteKey


#Dele App til annen tenant:
#https://login.microsoftonline.com/common/adminconsent?client_id=95f12ea4-41ec-45f0-97d3-f2bda3373b1e
