$filePath = "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\ResourceReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"

$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending
# Clear-Content -LiteralPath $filePath
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

$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOUPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$AllRDPVMs = $PremiumServers + $RDPServers + $HawaiiServers
$AllRDPVMsSorted = $AllRDPVMs | Sort-Object
$ServerOutput =@()
foreach($pc in $AllRDPVMsSorted)
{
    $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $pc -Filter "DeviceID='C:'"
    $testObject = [PSCustomObject]@{
        Name = Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
        HVHost =Invoke-Command -ComputerName $pc {Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object -ExpandProperty HostName}
        TotalDiskSpace = [Math]::Round($DiskInfo.Size/1GB,2)
        FreeDiskSpace = [Math]::Round($DiskInfo.freeSpace/1GB,2)
    }
    $ServerOutput += $testObject
    # $disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername $pc
    # $results = foreach ($disk in $disks)
    #         {
    #             if ($disk.Size -gt 0)
    #             {
    #                 $size = [math]::round($disk.Size/1GB,2)
    #                 $free = [math]::round($disk.FreeSpace/1GB,2)
    #                 $total = ($free/$size)
    #                 $baseline = 0.05
    #                 if($total -lt $baseline)
    #                 {
    #                 "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free 

    #                 }
    #                 else
    #                 {
    #                     "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free
    #                 }

    #             }
    #         }
    # $memory = Invoke-Command -HideComputerName $pc { Get-WmiObject Win32_OperatingSystem -Property FreePhysicalMemory | Select-Object -ExpandProperty FreePhysicalMemory}
    # $freeMemory = "`t{0} GB" -f ([math]::round(($memory / 1024 /1024), 2))

    # '==================='| Out-File -Append -LiteralPath  $filePath
    # $pc| Out-File -Append -LiteralPath  $filePath
    # '==================='| Out-File -Append -LiteralPath  $filePath
    # 'Free Disk Space:' | Out-File -Append -LiteralPath $filePath
    # $results | Out-File -Append -LiteralPath $filePath
    # 'Available Memory:' | Out-File -Append -LiteralPath $filePath
    # $freeMemory | Out-File -Append -LiteralPath $filePath

}
$ServerOutput | Export-Excel -Path $filePath -AutoSize -TableName RDPVMDiskData -WorksheetName "RDP VM Disk Report"