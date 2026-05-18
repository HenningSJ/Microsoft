
Set-CsTeamsMeetingPolicy -Identity Global -roomAttributeUserOverride Distinguish -roomPeopleNameUserOverride On -AllowTranscription $True 
Set-CsTeamsAiPolicy -Identity Global -SpeakerAttributionBYOD Enabled
