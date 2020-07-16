#this script shows all computers on the domain that have
#not checked in in over 30 days
#depends on active directory module

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "AD module available - proceeding"
    Import-Module ActiveDirectory
} else {
    Write-Host "ActiveDirectory module not available"
    exit 1001
}

$now = Get-Date

$thirtydays = $now.AddDays("-30")

$computers = Get-ADComputer -filter {whenChanged -ge $thirtydays}


#Write-Host "The following computers have not been seen by the domain server in over 30 days:"
$activeServers =@()
$serversWithoutCylance =@()
foreach ($computer in $computers){
    #Write-Host $computer.Name
    $doeshaveCylance = 'false'
    #$installedPrograms = Invoke-Command -ComputerName $computer.Name {Get-ItemProperty 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table -AutoSize}
    $service = Get-Service -Name "Cylance Unified Agent" -ComputerName $computer.Name -ErrorAction Ignore
    if($service)
    {
        $doeshaveCylance = 'true'
    }
    else {
        $serversWithoutCylance += $computer.Name
    }
}
$serversWithoutCylance