$ServersOuPath ='<Distinguished Name for OU where computers are stored>'
$Servers = Get-ADComputer -SearchBase $ServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$ActiveServers = @()
$RPCFailures = @()
foreach($PremiumServer in $Servers)
{
    $ServerName = Invoke-Command -ComputerName $PremiumServer {hostname}
    if($null -ne $ServerName)
    {
        $ActiveServers += $PremiumServer
    }
    else {
        $RPCFailures += $PremiumServer
    }
}
$ActiveServers | Out-File -FilePath "<FILE PATH FOR ACTIVE SERVERS LIST>"
$RPCFailures | Out-File -FilePath "<FILE PATH FOR STALE SERVERS LIST>"
