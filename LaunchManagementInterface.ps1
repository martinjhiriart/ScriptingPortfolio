$HostName = Read-Host "Enter Physical Server Name"
$manufacturer = Get-WmiObject -ComputerName $HostName Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer

if($Manufacturer -eq 'Dell Inc.')
{
    $URL = "https://" + $HostName + ":1311"
}
elseif($Manufacturer -eq 'Supermicro')
{
    $URL = "https://" + $HostName + ":8444"
}


Start-Process -FilePath $URL