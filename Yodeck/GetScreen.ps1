$screenName = "LSG-BGO-L508"

$screen = $screens | Where-Object { $_.name -eq $screenName }

$screen | Select-Object `
  id,
  name,
  @{n="online"; e={ $_.state.online }},
  @{n="last_seen"; e={ $_.state.last_seen }},
  @{n="workspace"; e={ $_.workspace.name }}

  