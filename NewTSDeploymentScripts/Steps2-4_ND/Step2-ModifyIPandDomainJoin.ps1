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
New-NetIPAddress -InterfaceAlias $ifcName -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway 10.100.0.1
Set-DnsClientServerAddress -InterfaceAlias $ifcName -ServerAddresses 10.100.0.2, 10.100.0.3

$ifcIndex = (Get-NetAdapter -Name $ifcName).ifIndex

Add-Computer -DomainName needleshosted.local -NewName $name -Credential needleshosted\administrator -Restart