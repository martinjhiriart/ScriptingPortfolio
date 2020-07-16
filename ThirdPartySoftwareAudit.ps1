$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOUPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$filePath = "\\HVSHEEV\C$\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\ThirdPartySoftwareAudit-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"

$AllRDPVMs = $PremiumServers + $RDPServers + $HawaiiServers
$AllServers = $AllRDPVMs | Sort-Object

$AuditOutput = @()
foreach($Server in $AllServers)
{
    $ListOfSoftware = Invoke-Command -ComputerName $Server { Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'} 
    foreach($Software in $ListOfSoftware)
    {
        if($Software.DisplayName -eq $null)
        {
            $InstalledSoftware = $Software."(default)"
        }
        else{
            $InstalledSoftware = $Software.DisplayName
        }
        $ThirdPartySoftwareObject = [PSCustomObject]@{
            Server = $Server
            SoftwareInstalled = $InstalledSoftware
            Version = $Software.DisplayVersion
        }
        $AuditOutput += $ThirdPartySoftwareObject
    }
}
$AuditOutput | Export-Excel -AutoSize -TableName ThirdPartySoftwareAudit -WorksheetName "Installed Software per VM" -Path $filePath
