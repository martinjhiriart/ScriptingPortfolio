#this script shows all computers on the domain that have
#not checked in in over 30 days
#depends on active directory module

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD module available - proceeding"
    Import-Module ActiveDirectory
}
else {
    Write-Host "ActiveDirectory module not available"
    exit 1001
}

$now = Get-Date

$thirtydays = $now.AddDays("-30")

$computers = Get-ADComputer -filter { whenChanged -ge $thirtydays }


#Write-Host "The following computers have not been seen by the domain server in over 30 days:"
# $activeServers =@()
$serversWithQuickbooks = @()
foreach ($computer in $computers) {
    #Write-Host $computer.Name
    $doeshaveQuickbooks = 'false'
    #$installedPrograms = Invoke-Command -ComputerName $computer.Name {Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize}
    $quickbooks = Invoke-Command -ComputerName $computer.Name { Get-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName | Where-Object -FilterScript { $_.DisplayName -like "QuickBooks" } | Format-Table -AutoSize }
    if ($quickbooks) {
        $doeshaveQuickbooks = 'true'
        $serversWithQuickbooks += $computer.Name
    }
}
$serversWithQuickbooks
