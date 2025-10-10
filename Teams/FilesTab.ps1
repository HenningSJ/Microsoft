#Det er to sentrale parametere i Teams Files Policy:
    #SPChannelFilesTab
        #Standard: Enabled
        #Hvis Disabled, vises ikke Filer-fanen i kanaler (selv om SharePoint fortsatt opprettes).
    #NativeFileEntryPoints  
        #Standard: Enabled
        #Hvis Disabled, fjernes muligheten til å laste opp filer fra OneDrive/SharePoint i Teams.
#Hvis en av disse er deaktivert i en policy som er tildelt brukerne, vil Filer-fanen ikke vises.

Import-Module MicrosoftTeams
Connect-MicrosoftTeams

Get-CsTeamsFilesPolicy

Set-CsTeamsFilesPolicy -Identity Global -SPChannelFilesTab Enabled -NativeFileEntryPoints Enabled
