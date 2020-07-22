$ServersOUPath = '<DISTINGUISHED NAME OF OU WITH SERVERS>'
$AllServers = Get-ADComputer -SearchBase $ServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$AllServersSorted = $Servers | Sort-Object
$ServersWithWINRM = @()
$ServersWithoutWINRM = @()

foreach($Server in $AllRDPVMsSorted)
{
    $WinRMTest = Test-NetConnection -ComputerName $Server -CommonTCPPort WINRM | Select-Object -ExpandProperty TCPTestSucceeded
    if($WinRMTest -eq $true)
    {
        $ServersWithWINRM += $Server
    }
    else
    {
        $ServersWithoutWINRM += $Server
    }
}
$ServersWithWINRM | Sort-Object | Out-File -Path "<FILE PATH FOR FINAL OUTPUT>\VMs With WINRM.txt"
$ServersWithoutWINRM | Sort-Object | Out-File -Path "<FILE PATH FOR FINAL OUTPUT>\VMs Without WINRM.txt"