Read-Host 'Enter Customer Name'
$CustomerOUName = Read-Host
New-ADOrganizationalUnit -Name $CustomerOUName -Path "OU=Customers,DC=TWCustomer,DC=local"