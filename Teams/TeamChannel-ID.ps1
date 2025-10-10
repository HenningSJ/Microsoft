Connect-MgGraph -Scopes "TeamsTab.Create","Group.ReadWrite.All"


Import-Module MicrosoftTeams
Connect-MicrosoftTeams

Get-Team | Format-Table DisplayName, GroupId

#DisplayName           GroupId
#-----------           -------
#Serit Tromsø          bd42de4c-3ab5-43e7-8b71-d64e42d58623
#Noah Test             cd6d60f9-8e4c-4bfc-b8e6-f6499c60146c
#Salg og markedsføring dbef42d8-9625-4551-a1df-53a0c613a43c
#Rudi-Testsite2        0f47d5e4-b272-4b6b-b2de-d3ce86bb0cd1
#TestSharegateMig      5a81ad6c-c114-4d01-8279-cc8a7f8c5b87
#Rudi-Testsite         40403214-6c6e-4de4-b788-df41ab4f820c
#Rudi-Testsite3        f8c90adb-186a-4505-bd77-473e748c3682


Get-TeamChannel -GroupId dbef42d8-9625-4551-a1df-53a0c613a43c

#Id                                                           DisplayName Description                                           MembershipType
#--                                                           ----------- -----------                                           --------------
#19:tB878kaCDFVSs6s0f6ieaR07LmR_dM6Lze80pexJy901@thread.tacv2 Generelt    Team for ansatte som jobber med salg og markedsføring       Standard

