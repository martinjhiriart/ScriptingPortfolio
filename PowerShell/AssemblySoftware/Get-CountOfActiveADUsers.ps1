$UsersOuPath ='<DISTINGUISHED NAME OF OU WITH AD USERS>'
$Users = Get-ADOrganizationalUnit -Filter {(Name -notlike 'Disabled*') -and (Name -notlike 'ACCOUNTS CLOSED')} -SearchBase $UsersOuPath -SearchScope OneLevel | Select-Object -ExpandProperty DistinguishedName | Sort-Object
$ActiveADUsers = @()
foreach ($User in $Users){
    $ActiveADUsers += Get-ADUser -Filter {Enabled -eq 'True'} -SearchBase $Customer | Select-Object -ExpandProperty Name
}
$ActiveADUsers | Measure-Object | Select-Object Count