$ServersOUPath = '<OU THAT CONTAINS SERVERS TO QUERY>'
$Servers = Get-ADComputer -SearchBase $ServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object

$filePath = "<FILE PATH FOR FINAL REPORT>\ThirdPartySoftwareAudit-" + "$(Get-Date -f MM-dd-yyyy)" + ".xlsx"
$AllServers = $Servers | Sort-Object

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
