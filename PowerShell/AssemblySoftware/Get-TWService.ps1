
$ServersOUPath = '<DISTINGUISHED NAME FOR OU HOLDING SERVERS>'
$AllServers = Get-ADComputer -SearchBase $ServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$filePath = "<FILE PATH FOR FINAL OUTPUT>" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"

$AllServersSorted = $AllRDPVMs | Sort-Object

$ServersWithTWService = @(
    "VMName"
)
foreach ($Server in $AllServers) {
    #Write-Host $Server.Name
    $DoesHaveTWService = 'false'
    #$installedPrograms = Invoke-Command -ComputerName $Server.Name {Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize}
    $TWService = Invoke-Command -ComputerName $Server { Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName | Where-Object -FilterScript { $_.DisplayName -like "TrialWorks Services" } | Format-Table -AutoSize }
    if ($TWService) {
        $DoesHaveTWService = 'true'
        $ServersWithTWService += $Server
    }
}
$ServersWithTWService | Export-Excel -Path $filePath -AutoSize -TableName ServersWithTWService -WorksheetName "Servers With TWService"