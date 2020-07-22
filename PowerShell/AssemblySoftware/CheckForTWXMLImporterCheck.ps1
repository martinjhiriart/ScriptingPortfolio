$AllServersOuPath = '<DISTNIGUISHED NAME OF OU WITH SERVERS TO QUERY>'
$AllServers = Get-ADComputer -SearchBase $AllServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$AllServersSorted = $AllServers | Sort-Object
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
$ServersWithXMLImporter | Out-File -Path "<FILE PATH FOR REPORT>\ServersWithXMLImporter.txt"