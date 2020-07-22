$user = Read-Host "Enter User Full Name"
$ADuser = Get-ADUser -Filter "Name -like '$user'" | Select-Object -ExpandProperty SamAccountName
Get-ADPrincipalGroupMembership -Identity $ADuser | Select-Object -ExpandProperty Name