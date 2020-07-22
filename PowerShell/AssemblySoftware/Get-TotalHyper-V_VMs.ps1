$HostServersOuPath ='<DISTINGUISHED NAME OF OU THAT HAS HYPER-V HOSTS>'
$PhysicalServers = @()
$PhysicalServers += Get-ADComputer -SearchBase $HostServersOuPath -Filter * | Select-Object -ExpandProperty Name
$PhysicalServers += Get-ADComputer -SearchBase $StorageServersOuPath -Filter * | Select-Object -ExpandProperty Name
$PhysicalServers | Measure-Object | Select-Object Count
$VMs =@()
$AllServers =@()
foreach($Server in $PhysicalServers)
{
    $VMs += Invoke-Command -HideComputerName $Server {Get-VM | Where-Object {($_.Name -notlike "*-*OFF")} | Select-Object Name,State,PSComputerName} | Select-Object Name | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName
}
$AllServers = $PhysicalServers + $VMs | Sort-Object

$AllServers