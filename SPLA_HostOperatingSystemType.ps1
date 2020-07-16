$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$secondServersOuPath = 'OU=Storage Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = @()
$servers += Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name
$servers += Get-ADComputer -SearchBase $secondServersOuPath -Filter * | Select-Object -ExpandProperty Name

$SPLAPath = "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\SPLA_Server_Audit2.xlsx"
$ServerOSTypes = @()
$ServerNumberOfCPUs = @()
foreach($server in $servers)
{
    $ServerOSTypes += Invoke-Command -ComputerName $server {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | Select-Object ProductName,InstallationType} | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName
    $ServerNumberOfCPUs += Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server | Select-Object Name,NumberOfLogicalProcessors
}
$ServerOSTypes | Export-Excel -Path $SPLAPath -AutoSize -TableName HostOperatingSystems -WorksheetName "SPLA Host OS Versions"
$ServerNumberOfCPUs | Export-Excel -Path $SPLAPath -AutoSize -TableName HostCPUCount -WorksheetName "Count of CPUs Per Host"