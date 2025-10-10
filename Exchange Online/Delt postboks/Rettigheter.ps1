
# Full Access kan gi problemer med synkronisering av epost pga. automapping.
# Dette skriptet fjerner eksisterende Full Access-rettigheter og legger dem til på nytt uten automapping.

# Variabler – erstatt med riktig brukernavn og postboksnavn
$SharedMailbox = "deltpostboks@dittdomene.no"
$User = "bruker@dittdomene.no"

#$Users = @("bruker1@dittdomene.no", "bruker2@dittdomene.no", "bruker3@dittdomene.no")
#foreach ($User in $Users) {
    # Fjern eksisterende Full Access-rettigheter
    Remove-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -Confirm:$false

    # Legg til Full Access uten automapping
    Add-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -AutoMapping:$false
#}
# Fjern eksisterende Full Access-rettigheter
Remove-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -Confirm:$false

# Legg til Full Access uten automapping
Add-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -AutoMapping:$false


# Kanskje det vil være mer hensiktsmessig å gi kun Send As-rettigheter:
# Variabler – erstatt med riktig brukernavn og postboksnavn
$SharedMailbox = "deltpostboks@dittdomene.no"
$User = "bruker@dittdomene.no"

# Fjern Full Access-rettigheter
Remove-MailboxPermission -Identity $SharedMailbox -User $User -AccessRights FullAccess -Confirm:$false

# Legg til Send As-rettigheter
Add-RecipientPermission -Identity $SharedMailbox -Trustee $User -AccessRights SendAs -Confirm:$false

