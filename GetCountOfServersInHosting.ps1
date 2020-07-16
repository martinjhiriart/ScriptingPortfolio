$HostServersOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$StorageServersOuPath = 'OU=Storage Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PhysicalServers = @()
$PhysicalServers += Get-ADComputer -SearchBase $HostServersOuPath -Filter * | Select-Object -ExpandProperty Name
$PhysicalServers += Get-ADComputer -SearchBase $StorageServersOuPath -Filter * | Select-Object -ExpandProperty Name
$PhysicalServers | Measure-Object | Select-Object Count
$VMs =@()
$AllServers =@()
foreach($Server in $PhysicalServers)
{
    $VMs += Invoke-Command -HideComputerName $Server {Get-VM | Where-Object {($_.Name -notlike "*-*OFF")} | Select-Object Name,State,PSComputerName} | Select-Object Name | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName #| Export-Csv -NoTypeInformation -Append -Path $CsvPath 
}
$AllServers = $PhysicalServers + $VMs | Sort-Object

$AllServers