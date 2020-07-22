$serversOuPath ='<DISTINGUISHED NAME OF OU WITH SERVERS>'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending

$filePath = "<FILE PATH FOR REPORT>\HostSerialNumberReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".txt"
Clear-Content -LiteralPath $filePath
foreach($pc in $servers)
{
    '==================='| Out-File -Append -LiteralPath  $filePath
    $pc| Out-File -Append -LiteralPath  $filePath
    '==================='| Out-File -Append -LiteralPath  $filePath
    Invoke-Command -HideComputerName $pc {wmic bios get serialnumber} | Out-File -Append -LiteralPath $filePath
}