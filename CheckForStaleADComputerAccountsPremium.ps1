$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$ActivePremiumServers = @()
$RPCFailures = @()
foreach($PremiumServer in $PremiumServers)
{
    $ServerName = Invoke-Command -ComputerName $PremiumServer {hostname}
    if($null -ne $ServerName)
    {
        $ActivePremiumServers += $PremiumServer
    }
    else {
        $RPCFailures += $PremiumServer
    }
}
$ActivePremiumServers | Out-File -FilePath "C:\Automation\Audit\ActivePremiumServers.txt"
$RPCFailures | Out-File -FilePath "C:\Automation\Audit\StalePremiumServers.txt"
