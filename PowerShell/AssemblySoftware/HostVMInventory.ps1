$serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending
    $filePath = "C:\Reports\HostInventoryReport-" + "$(Get-Date -f MM-dd-yyyy)" + ".txt"
    Clear-Content -LiteralPath $filePath
    '_________________________' | Out-File -Append -LiteralPath $filePath
    ''| Out-File -Append -LiteralPath  $filePath
    'TW Hosting Inventory Report' | Out-File -Append -LiteralPath  $filePath
    'Report generated on' + ' ' + $((Get-Date).ToString()) | Out-File -Append -LiteralPath $filePath
    '_________________________' | Out-File -Append -LiteralPath $filePath
    ''| Out-File -Append -LiteralPath  $filePath
    foreach ($server in $servers) {
        '==================='| Out-File -Append -LiteralPath  $filePath
        $server| Out-File -Append -LiteralPath  $filePath
        '==================='| Out-File -Append -LiteralPath  $filePath
        Invoke-Command -HideComputerName $server {Get-VM | Where-Object {$_.State -eq 'Running'} | Select-Object Name | Select-Object -ExpandProperty Name}| Out-File -Append -LiteralPath  $filePath
         ''| Out-File -Append -LiteralPath  $filePath
    }
    
    $uri = "https://outlook.office.com/webhook/36c3511c-5d2c-4c5c-bd95-590992f083da@c18603c9-c364-4d5f-a43f-ee2024d5eebd/IncomingWebhook/4396711558814aae97d8bd0a9baaf2f0/8d996b17-a4e1-42c8-ade3-b5fe682d88b4"
    $body = ConvertTo-JSON @{
    text = 'Host-VM Inventory Report Completed for ' + $(Get-Date)
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'