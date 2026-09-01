<#finn pfx
Get-ChildItem Cert:\CurrentUser\My | 
Where-Object {$_.Subject -like "*Serit PnP PowerShell*"} |
Select Subject, Thumbprint, NotAfter
#>

#Eller
#Get-PfxCertificate -FilePath "C:\Cert\PnP.pfx"

Connect-PnPOnline `
    -Url "https://dagenborg.sharepoint.com/sites/Felles" `
    -ClientId "a7a5183a-e869-4a62-bed5-9db047261207" `
    -Tenant "dagenborg.onmicrosoft.com" `
    -Thumbprint "F32B2D08838DD3A6134B31C1ED391BBB3935E089"

#Test
#Get-PnPWeb