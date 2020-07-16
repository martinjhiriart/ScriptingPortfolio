$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending

$filePath = "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\HostResourceReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"
Clear-Content -LiteralPath $filePath
$HostOutput =@()
foreach($pc in $servers)
{
    if($pc -eq "HVHOST17")
    {
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='H:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
    }
    elseif($pc -eq "HVSQLHOST1")
    {
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='C:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
    }
    elseif($pc -eq "HVDFS2")
    {
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='F:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
    }
    elseif($pc -eq "HVHOST3")
    {
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='D:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject

        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='E:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
        
    }
    elseif($pc -eq "HVDFS1")
    {
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='D:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject

        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='E:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject

        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='F:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
        
    }
    else{
        $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='D:'"
        $HostObject = [PSCustomObject]@{
            Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
            TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
            FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
            DiskName = $DiskInfo.DeviceID
        }
        $HostOutput += $HostObject
    }
}
$HostOutput | Export-Excel -Path $filePath -AutoSize -TableName HostDiskData -WorksheetName "Host Disk Report"