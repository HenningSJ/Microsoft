Connect-ExchangeOnline

new-transportrule -name "Bypass Spamfilter for pensjonerte postbokser" -sentto "are.fagerheim@tromso.serit.no", "yngve.karlsen@tromso.serit.no"-setscl -1

Get-TransportRule "Bypass Spamfilter for pensjonerte postbokser" | fl Name,SetSCL,SentTo