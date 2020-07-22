$AllServersOuPath = #Distinguished name of OU in Active Directory that has the server you want to query
$AllServers = Get-ADComputer -SearchBase $AllServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object



$AllServersSorted = $AllServers | Sort-Object

$filePath = #<File path to output report to> + "$(Get-Date -f MM-dd-yyyy)" + ".csv"
$FileExists = Test-Path -Path $filePath
if($FileExists -eq $true)
{
    Clear-Content -LiteralPath $filePath
}
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
}
$ServerOutput | Export-Excel -Path $filePath -AutoSize -TableName RDPVMDiskData -WorksheetName "Server Disk Report"