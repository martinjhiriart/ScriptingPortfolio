$IPAddresses = Get-DnsServerResourceRecord -ComputerName Hostrex3 -ZoneName "<DNS ZONE NAME>"
$IPObject = foreach($IPAddress in $IPAddresses)
{
    [PSCustomObject]@{
        Hostname = $IPAddress.Hostname
        RecordData = $IPAddress.RecordData
        IPAddress = $([system.version]($IPAddress.RecordData.ipv4address.IPAddressToString))
    }
}
$IPObject
