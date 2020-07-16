$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
    $CsvPath = "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Reports\HostVMInventoryReport-" + "$(Get-Date -f MM-dd-yyyy)"+ ".csv"
    $CheckIfFileExists = Test-Path -Path $CsvPath
    if($CheckIfFileExists -eq $true)
    {
        Clear-Content -Path $CsvPath
    }
    foreach ($server in $servers) {
        Invoke-Command -HideComputerName $server {Get-VM | Where-Object {($_.Name -notlike "*-*OFF")} | Select-Object Name,State,PSComputerName} | Select-Object Name,State,PSComputerName | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName | Export-Csv -NoTypeInformation -Append -Path $CsvPath 
    }

    $uri = "https://outlook.office.com/webhook/36c3511c-5d2c-4c5c-bd95-590992f083da@c18603c9-c364-4d5f-a43f-ee2024d5eebd/IncomingWebhook/4396711558814aae97d8bd0a9baaf2f0/8d996b17-a4e1-42c8-ade3-b5fe682d88b4"
    $body = ConvertTo-JSON @{
    text = 'Host-VM Inventory Report Completed for ' + $(Get-Date)
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
