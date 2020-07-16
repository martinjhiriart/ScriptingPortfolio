$CustomersOuPath ='OU=Greenspan,DC=GLF,DC=local'
$Customers = Get-ADOrganizationalUnit -Filter {(Name -notlike 'Disabled*') -and (Name -notlike 'ACCOUNTS CLOSED')} -SearchBase $CustomersOuPath | Select-Object -ExpandProperty DistinguishedName | Sort-Object
$ActiveADUsers = @()
foreach ($Customer in $Customers){
    $ActiveADUsers += Get-ADUser -Filter {Enabled -eq 'True'} -SearchBase $Customer | Select-Object -ExpandProperty Name
}
$ActiveADUsers | Measure-Object | Select-Object Count