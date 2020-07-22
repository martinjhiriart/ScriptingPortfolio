$FQDN = Read-Host "Enter Server Name"
$ReleaseVersion = Invoke-Command -HideComputerName $FQDN {(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release}
if($ReleaseVersion -ge 378389)
{
    $NETFrameworkVersion = "4.5"
}
if($ReleaseVersion -ge 378675)
{
    $NETFrameworkVersion = "4.5.1"
}
if($ReleaseVersion -ge 379893)
{
    $NETFrameworkVersion = "4.5.2"
}
if($ReleaseVersion -ge 393295)
{
    $NETFrameworkVersion = "4.6"
}
if($ReleaseVersion -ge 394254)
{
    $NETFrameworkVersion = "4.6.1"
}
if($ReleaseVersion -ge 394802)
{
    $NETFrameworkVersion = "4.6.2"
}
if($ReleaseVersion -ge 460798)
{
    $NETFrameworkVersion = "4.7"
}
if($ReleaseVersion -ge 461308)
{
    $NETFrameworkVersion = "4.7.1"
} 
if($ReleaseVersion -ge 461808)
{
    $NETFrameworkVersion = "4.7.2"
}
if($ReleaseVersion -ge 528040)
{
    $NETFrameworkVersion = "4.8 or later"
}
elseif($ReleaseVersion -lt 378389) {
    Write-Error ".NET Framework 4.5 or later not installed."
}
$NETFrameworkVersion