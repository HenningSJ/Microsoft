Set-CsTeamsMeetingPolicy -Identity Global -RoomAttributeUserOverride Distinguish
Set-CsTeamsMeetingPolicy -Identity Global -roomAttributeUserOverride Distinguish -roomPeopleNameUserOverride On -AllowTranscription $True 
