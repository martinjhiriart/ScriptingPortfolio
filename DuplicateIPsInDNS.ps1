$IPAddresses = Get-DnsServerResourceRecord -ComputerName Hostrex3 -ZoneName "TWCustomer.local"
$IPObject = foreach($IPAddress in $IPAddresses)
{
    [PSCustomObject]@{
        Hostname = $IPAddress.Hostname
        RecordData = $IPAddress.RecordData
        IPAddress = $([system.version]($IPAddress.RecordData.ipv4address.IPAddressToString))
    }
}
$IPObject
