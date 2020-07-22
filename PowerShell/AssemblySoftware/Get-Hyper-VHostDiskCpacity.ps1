$serversOuPath ='<DISTINGUISHED NAME FOR OU WITH HYPER-V HOSTS>'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending

$filePath = "<FILE PATH FOR FINAL REPORT>\HostResourceReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"
Clear-Content -LiteralPath $filePath
$HostOutput =@()
foreach($pc in $servers)
{
    $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='D:'"
    $HostObject = [PSCustomObject]@{
        Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
        TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
        FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
        DiskName = $DiskInfo.DeviceID
    }
    $HostOutput += $HostObject
}
$HostOutput | Export-Excel -Path $filePath -AutoSize -TableName HostDiskData -WorksheetName "Host Disk Report"