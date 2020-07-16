$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOUPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$filePath = "\\HVSHEEV\C$\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\ServersWithTWService-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"

$AllRDPVMs = $PremiumServers + $RDPServers + $HawaiiServers
$AllServers = $AllRDPVMs | Sort-Object

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