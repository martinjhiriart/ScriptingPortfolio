$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$ActiveRDPServers = @()
$RPCFailures = @()
foreach($RDP in $RDPServers)
{
    $ServerName = Invoke-Command -ComputerName $RDP {hostname}
    if($null -ne $ServerName)
    {
        $ActiveRDPServers += $RDP
    }
    else {
        $RPCFailures += $RDP
    }
}
$ActiveRDPServers | Out-File -FilePath "C:\Automation\Audit\ActiveRDPServers.txt"
$RPCFailures | Out-File -FilePath "C:\Automation\Audit\StaleRDPServers.txt"
