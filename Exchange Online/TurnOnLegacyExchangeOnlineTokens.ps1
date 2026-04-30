#Forstår det slik at enkelte (eldre) Outlook add-ins bruker legacy tokens. Dette er aldrende teknologi, som avvikles av Microsoft.
#Dette er en midliertidig fix der add-ins har sluttet å fungere pga. dette.

Import-Module -name exchangeonlinemanagement
Update-Module -Name exchangeonlinemanagement
Connect-ExchangeOnline


set-authenticationpolicy -allowlegacyexchangetokens -identity "legacyexchangeonlinetokens"

get-authenticationpolicy -allowlegacyexchangetokens