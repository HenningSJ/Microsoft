Get-CsTeamsMeetingPolicy -Identity Global | Format-List *
Get-CsTeamsMeetingPolicy -Identity Global | select RoomAttributeUserOverride, RoomPeopleNameUserOverride, AllowTranscription
