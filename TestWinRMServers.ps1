$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOUPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$AllRDPVMs = $PremiumServers + $RDPServers + $HawaiiServers
$AllRDPVMsSorted = $AllRDPVMs | Sort-Object
$VMsWithWINRM = @()
$VMsWithoutWINRM = @()

foreach($Server in $AllRDPVMsSorted)
{
    $WinRMTest = Test-NetConnection -ComputerName $Server -CommonTCPPort WINRM | Select-Object -ExpandProperty TCPTestSucceeded
    if($WinRMTest -eq $true)
    {
        $VMsWithWINRM += $Server
    }
    else
    {
        $VMsWithoutWINRM += $Server
    }
}
$VMsWithWINRM | Sort-Object | Out-File -Path "C:\Automation\Audit\VMs With WINRM.txt"
$VMsWithoutWINRM | Sort-Object | Out-File -Path "C:\Automation\Audit\VMs Without WINRM.txt"