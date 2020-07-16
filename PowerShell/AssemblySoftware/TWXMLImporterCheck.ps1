$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$PremiumServersOuPath = 'OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOuPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$AllServers =@()
$AllServers = $RDPServers + $PremiumServers + $HawaiiServers | Sort-Object
$ServersWithXMLImporter =@()
$ServersWithoutImporter =@()
foreach($Server in $AllServers)
{
    $ImporterCheck = Invoke-Command -ComputerName $Server {Get-Service | Where-Object{$_.Name -eq "TWImportService"} | Select-Object -ExpandProperty Name}
    if($null -ne $ImporterCheck)
    {
        $ServersWithXMLImporter += $Server
    }
    else
    {
        $ServersWithoutImporter += $Server
    }
}
$ServersWithXMLImporter | Out-File -Path "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\ServersWithXMLImporter.txt"