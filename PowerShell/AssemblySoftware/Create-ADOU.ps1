Read-Host 'Enter Customer Name'
$CustomerOUName = Read-Host
New-ADOrganizationalUnit -Name $CustomerOUName -Path "<DISTINGUISHED NAME FOR OU TO BE CREATED IN"