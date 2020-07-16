$Servers = (Get-ADGroupMember -Identity "TWSearchServers" | Select-Object Name).Name

Enable-WSManCredSSP -Role Client -DelegateComputer $Servers -Force

$creds = Get-Credential

foreach($server in $Servers)
{
   Invoke-Command -HideComputerName $server {Install-WindowsFeature RSAT-AD-Powershell; Enable-WSManCredSSP -Role Server -Force}
   Invoke-Command -HideComputerName $server -Credential $creds -Authentication Credssp {Install-ADServiceAccount -Identity "gmsaTWSearch"; Test-ADServiceAccount -Identity "gmsaTWSearch"}
   Invoke-Command -HideComputerName $server {Disable-WSManCredSSP -Role Server; Get-WSManCredSSP}
}
