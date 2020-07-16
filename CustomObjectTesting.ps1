$Servers = @(
    "TWManager",
    "TWManager1"
)

$serverOutput =@()

foreach($server in $Servers)
{
    $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $server -Filter "DeviceID='C:'"
    $testObject = [PSCustomObject]@{
        Name = Invoke-Command -ComputerName $server {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
        HVHost =Invoke-Command -ComputerName $server {Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object -ExpandProperty HostName}
        TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
        FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
    }
    $serverOutput += $testObject
}
$serverOutput | Export-Csv -Path "C:\Automation\Audit\TEST2.csv"
