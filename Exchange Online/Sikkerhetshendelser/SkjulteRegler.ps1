Connect-ExchangeOnline

#   Dette viser alle synlige regler
#Get-InboxRule -Mailbox <brukerens e-postadresse> | Format-Table Name, Enabled, Description

#   Dette viser alle regler, inkludert skjulte regler
Get-InboxRule -mailbox lise-marie.sandvold@hemis.no -IncludeHidden


#   Sjekk etter skjulte eller mistenkelige regle Skjulte regler kan være:
#       Regler som videresender e-post til eksterne adresser.
#       Regler som sletter eller flytter e-post til uvanlige mapper.
#       Regler med navn som ser tomme eller rare ut.
Get-InboxRule -Mailbox lise-marie.sandvold@hemis.no | Format-List Name, Description, ForwardTo, RedirectTo, DeleteMessage, MoveToFolder

#   Hvis du finner en mistenkelig regel, kan du fjerne den med følgende kommando:
Remove-InboxRule -Mailbox e-post -Identity "regelnavn"
