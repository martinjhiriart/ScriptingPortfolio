$ADGroup = Read-Host "Enter Security Group Name"
Get-ADGroupMember -Identity $ADGroup | Select-Object Name