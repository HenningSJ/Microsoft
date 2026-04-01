# Sett inn et kjent domene i tenanten, f.eks. contoso.onmicrosoft.com eller bedriftens e-postdomene
$TenantDomain = "nordtre.onmicrosoft.com"

# Hent OIDC-konfig
$oidc = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantDomain/v2.0/.well-known/openid-configuration"

# Ekstraher Tenant ID fra issuer (format: https://login.microsoftonline.com/{tenantid}/v2.0)
$TenantId = ($oidc.issuer -split '/')[3]

Write-Host "Tenant ID: $TenantId"


#Eltro:
#185b631d-f345-4e08-833d-70d929ead841

#HPNN
#5b2363ca-c61b-4340-bc99-efcab96c4df9

#IBID
#256c6ac2-bdec-4852-894d-4995d602734f

#NT Entreprenør
#69104e7f-6c38-41b7-aedf-ba60ffdc6668

#NTC
#8e5367a7-2ca1-49d1-978c-8c5c56aa874d
