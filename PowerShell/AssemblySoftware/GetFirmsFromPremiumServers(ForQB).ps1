$premiumServer = Read-Host "Enter Premium Server Name"
Get-ADGroupMember -Identity $premiumServer | Select-Object Name