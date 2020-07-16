$device = "localhost"
$community = "mepush"
$retries = '2'
$timeout = '1000'
function Get-SNMP {
    Param ([string]$x)
    $snmp = New-Object -ComObject olePrn.OleSNMP
    $snmp.open($device,$community,$retries,$timeout)
    $snmp.get($x)
}

Get-SNMP -x '.1.3.6.1.4.1.674.10892.1.1900.10.1.12.1.1'