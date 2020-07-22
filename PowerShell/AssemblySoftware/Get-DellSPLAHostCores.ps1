$serversOuPath ='<DISTINGUISHED NAME OF OU WITH PHYSICAL SERVERS>'
$servers = @()
$servers += Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name

$SPLAPath = "<FILE PATH FOR FINAL REPORT>\SPLA_Server_Audit.xlsx"
$ServerOSTypes = @()
$ServerNumberOfCPUs = @()
foreach($server in $servers)
{
    $ServerOSTypes += Invoke-Command -ComputerName $server {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object ProductName,InstallationType} | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName
    $ServerNumberOfCPUs += Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server | Select-Object Name,NumberOfLogicalProcessors
}
$ServerOSTypes | Export-Excel -Path $SPLAPath -AutoSize -TableName HostOperatingSystems -WorksheetName "SPLA Host OS Versions"
$ServerNumberOfCPUs | Export-Excel -Path $SPLAPath -AutoSize -TableName HostCPUCount -WorksheetName "Count of CPUs Per Host"