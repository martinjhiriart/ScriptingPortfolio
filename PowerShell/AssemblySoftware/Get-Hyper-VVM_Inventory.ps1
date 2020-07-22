$serversOuPath ='<DISTINGUISHED NAME OF OU WITH HYPER-V HOSTS>'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
    $CsvPath = "<FILE PATH FOR FINAL OUTPUT>\HostVMInventoryReport-" + "$(Get-Date -f MM-dd-yyyy)"+ ".csv"
    $CheckIfFileExists = Test-Path -Path $CsvPath
    if($CheckIfFileExists -eq $true)
    {
        Clear-Content -Path $CsvPath
    }
    foreach ($server in $servers) {
        Invoke-Command -HideComputerName $server {Get-VM | Where-Object {($_.Name -notlike "*-*OFF")} | Select-Object Name,State,PSComputerName} | Select-Object Name,State,PSComputerName | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName | Export-Csv -NoTypeInformation -Append -Path $CsvPath 
    }

    $uri = "<URI FOR OPTIONAL MICROSOFT TEAMS NOTIFICATION>"
    $body = ConvertTo-JSON @{
    text = 'Host-VM Inventory Report Completed for ' + $(Get-Date)
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
