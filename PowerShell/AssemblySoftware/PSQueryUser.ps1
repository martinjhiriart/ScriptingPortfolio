Import-Module PSTerminalServices
$Server = Read-Host "Enter Server Name"
Invoke-Command -ComputerName $Server -Credential  {Get-TSSession -ComputerName $Server | Where-Object {$_.UserName -ne ""} | Select-Object UserName,WindowStationName,State,LoginTime}