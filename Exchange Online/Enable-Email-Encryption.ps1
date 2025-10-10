

########                                                    ########
###      Sette opp Epost kryptering (RMS) (Ikke S/MIME)          ###
########                                                    ########

# https://learn.microsoft.com/en-us/purview/set-up-new-message-encryption-capabilities

# Den simpleste formen for kryptering
# Krever Microsoft Subscription lisens

# Connect
Connect-ExchangeOnline

# Sjekk om kryptering er aktivert i tenant
# Sjekk om "AzureRMSLicensingEnabled" står til $True
Get-IRMConfiguration

# "This enables Microsoft Purview Message Encryption."
# Står den til $false så må den settes til $True
Set-IRMConfiguration -AzureRMSLicensingEnabled $True

# Kjør en test
# Test-IRMConfiguration -Sender rudi.rognli@idemo.no -Recipient rudi.rognli@tromso.serit.no
Test-IRMConfiguration -Sender Sissel.Haukebo.Samuelsen@Oddberg.no -Recipient Erik.Andreas.Schilbred@Oddberg.no

# Senario1: Får "PASS", alt er ok, du er ferdig

# Senario2: Får ikke noe output ved å kjøre "Test-IRMConfiguration", da må man bare kjøre alle kommandoene,
#           spesielt "Enable-AipService"

# Senario3: Feilmelding "Failed to acquire RMS templates", da må man kjøre følgende kommandoer:

Install-Module AipService -Force

Connect-AipService

# "InternalLicensingEnabled" specifies whether to enable IRM features for messages that are sent- 
# to internal recipients. "True" is the default value in Exchange Online. 
$RMSConfig = Get-AipServiceConfiguration
$LicenseUri = $RMSConfig.LicensingIntranetDistributionPointUrl
Set-IRMConfiguration -LicensingLocation $LicenseUri
Set-IRMConfiguration -InternalLicensingEnabled $true

# Sjekk at AipService står til "Enabled"
Get-AipService

# Står den til "Disabled" så kjører du følgende kommando for å aktivere
Enable-AipService

# Test på nytt nå å se om det fungerer
Test-IRMConfiguration -Sender rudi.rognli@idemo.no -Recipient rudi.rognli@tromso.serit.no

# Konklusjon er at alle disse må stå til "True", og AipService må stå til "Enabled"
# InternalLicensingEnabled                   : True
# ExternalLicensingEnabled                   : True
# AzureRMSLicensingEnabled                   : True
# AipService                                 : Enabled



