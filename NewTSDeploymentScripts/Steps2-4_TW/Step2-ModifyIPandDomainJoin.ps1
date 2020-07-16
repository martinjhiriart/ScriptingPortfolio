#Set Variables
$name = ""
$IPAddress = ""
$ifcName = "Ethernet"
$ifcIndex = ""

#Prompt User for Name
$name = Read-Host -Prompt "Please enter the VM Name"

#Prompt User for IP Address
$IPAddress = Read-Host -Prompt "Please Enter the IP Address"

#Disable IPV6
Disable-NetAdapterBinding -Name $ifcName -ComponentID ms_tcpip6 -PassThru

#Set IP Address/DNS/WINS Settings
New-NetIPAddress -InterfaceAlias $ifcName -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway 10.99.0.1
Set-DnsClientServerAddress -InterfaceAlias $ifcName -ServerAddresses 192.168.99.13, 192.168.99.5

$ifcIndex = (Get-NetAdapter -Name $ifcName).ifIndex

Add-Computer -DomainName twcustomer.local -NewName $name -Credential twcustomer\administrator -Restart