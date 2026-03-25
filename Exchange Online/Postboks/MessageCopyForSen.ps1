Connect-ExchangeOnline

set-mailbox -identity resepsjon@sommaroy.no -MessageCopyForSentAsEnabled $true
set-mailbox -identity resepsjon@sommaroy.no -MessageCopyForSendOnBehalfEnabled $true