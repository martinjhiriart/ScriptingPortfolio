$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending

$filePath = "C:\Automation\HostSerialNumberReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".txt"
Clear-Content -LiteralPath $filePath
foreach($pc in $servers)
{
    '==================='| Out-File -Append -LiteralPath  $filePath
    $pc| Out-File -Append -LiteralPath  $filePath
    '==================='| Out-File -Append -LiteralPath  $filePath
    Invoke-Command -HideComputerName $pc {wmic bios get serialnumber} | Out-File -Append -LiteralPath $filePath
}