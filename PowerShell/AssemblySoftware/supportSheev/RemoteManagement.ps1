Clear-Host
$domain = $args[0]
$domainUser = Read-Host 'Enter Username for '$domain
$domainUserName = $domain+'\'+$domainUser
$domainPassword = Read-Host 'Enter Password' -AsSecureString
$domainCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $domainUserName, $domainPassword
Write-Host '============================' -ForegroundColor Cyan
Write-Host 'Remote VM Management Console' -ForegroundColor Magenta
Write-Host '============================' -ForegroundColor Cyan
$pcName = Read-Host 'Enter VM Name'
$pc = "$pcName`.$domain"
$port = Invoke-Command -HideComputerName $pc -Credential $domainCreds { Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object PortNumber} | Select-Object -ExpandProperty PortNumber;
$disks = get-wmiobject -class "Win32_LogicalDisk" -namespace "root\CIMV2" -computername $pc -Credential $domainCreds
$ipAddr = Invoke-Command -HideComputerName $pc -Credential $domainCreds {Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript {$_.IPAddress -ne '127.0.0.1'} | Sort-Object -Property InterfaceIndex | Select-Object -ExpandProperty IPAddress}
        $results = foreach ($disk in $disks)
        {
            if ($disk.Size -gt 0)
            {
                $size = [math]::round($disk.Size/1GB,2)
                $free = [math]::round($disk.FreeSpace/1GB,2)
                $total = ($free/$size)
                $baseline = 0.05
                if($total -lt $baseline)
                {
                  "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free 

                }
                else
                {
                    "`n`tDrive",$disk.Name, "{0:N2} GB" -f $free
                }

            }
        }

$hostName = Invoke-Command -HideComputerName $pc -Credential $domainCreds { Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object HostName} | Select-Object -ExpandProperty HostName;
$pcFQDNName = Invoke-Command -HideComputerName $pc -Credential $domainCreds {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
$FQDNdomain = Invoke-Command -HideComputerName $pc -Credential $domainCreds { Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ -Name Domain | Select-Object Domain} | Select-Object -ExpandProperty Domain;
$users = Invoke-Command -HideComputerName $pc -Credential $domainCreds {query user} 

Write-Host ' '
Write-Host '============================' -ForegroundColor Magenta
Write-Host 'Virtual Machine Information' -ForegroundColor Cyan
Write-Host '============================' -ForegroundColor Magenta
Write-Host 'Computer Name: ' -NoNewline -ForegroundColor Yellow
Write-Host $pcFQDNName`.$FQDNdomain
Write-Host 'RDP Port Number: ' -NoNewline -ForegroundColor Yellow
Write-Output $port 
Write-Host 'Free Disk Space:' -NoNewline -ForegroundColor Yellow
Write-Host $results
Write-Host 'Host Server: ' -NoNewline -ForegroundColor Yellow
Write-Host $hostName -ForegroundColor Green
Write-Host 'IP Address(es):' -ForegroundColor Yellow
Write-Output $ipAddr
Write-Host 'Current Users:' -ForegroundColor Yellow
Write-Output $users
Write-Host '___________________' -ForegroundColor Magenta
Write-Host ' '

Write-Host 'Open Advanced Management Console?' -NoNewline -ForegroundColor Yellow
Write-Host '(Y/N): ' -NoNewline
$advMgmt = Read-Host
switch($advMgmt)
{
    'Y'{
        . .\AdvancedManagement.ps1 $port $pcFQDNName $domainCreds
        
    }
    'N'{
        Clear-Host
    }
}
