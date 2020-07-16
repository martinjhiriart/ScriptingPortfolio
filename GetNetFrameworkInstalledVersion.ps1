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
foreach($computer in $computers)
{
    $releaseVersion = Invoke-Command -HideComputerName $computer.Name {(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release}
    if($releaseVersion -ge 378389)
    {
        $installedVersion = "4.5"
    }
    if($releaseVersion -ge 378675)
    {
        $installedVersion = "4.5.1"
    }
    if($releaseVersion -ge 379893)
    {
        $installedVersion = "4.5.2"
    }
    if($releaseVersion -ge 393295)
    {
        $installedVersion = "4.6"
    }
    if($releaseVersion -ge 394254)
    {
        $installedVersion = "4.6.1"
    }
    if($releaseVersion -ge 394802)
    {
        $installedVersion = "4.6.2"
    }
    if($releaseVersion -ge 460798)
    {
        $installedVersion = "4.7"
    }
    if($releaseVersion -ge 461308)
    {
        $installedVersion = "4.7.1"
    } 
    if($releaseVersion -ge 461808)
    {
        $installedVersion = "4.7.2"
    }
    if($releaseVersion -ge 528040)
    {
        $installedVersion = "4.8 or later"
    }
    elseif($releaseVersion -lt 378389) {
        Write-Error ".NET Framework 4.5 or later not installed."
    }
    Write-Host "======================="
    Write-Host $computer.Name
    Write-Host "======================="
    Write-Host ".NET Framework $installedVersion is currently installed"
    Write-Host ""
    Write-Host ""
}
