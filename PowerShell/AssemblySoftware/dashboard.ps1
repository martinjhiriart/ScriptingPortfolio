#Command to set the theme of the dashboard
$theme = Get-UDTheme -Name 'DarkRounded'
#Variable to store all of the different pages for the dashboard
$Pages = @()

$ErrorActionPreference = "SilentlyContinue"

#Home Page
$Pages += New-UDPage -Name "Home" -Content{
        New-UDRow -Columns {
        New-UDColumn -SmallOffset 4 -SmallSize 3 -Content {
            New-UDCard -Title "Information" -Text "This is the Home Page for Sidious"
        }
    }
}
$Pages += New-UDPage -Name "VM Information" -Icon desktop -Content{
        New-UDColumn -SmallSize 3 -Content {
            New-UDInput -Title "Server Info" -Endpoint {
                param(
                    [ValidateSet("TWCustomer.local","NeedlesHosted.local", "CS.Local", "GLF.local", "PEJ.local", "PN.local", "PWD.local", "RLG.local", "SLF.local", "WK.local", "WS.local")]$Domain,
                    #[Parameter(Mandatory)]
                    [String]$DomainUserName,
                    [SecureString]$DomainUserPassword,
                    #[Parameter(Mandatory)]
                    [String]$ServerName
                    )
                    $domainUser = "$Domain\$DomainUserName"
                    #$domainPassword = ConvertTo-SecureString $DomainUserPassword -AsPlainText -Force
                    $Credentials = New-Object System.Management.Automation.PSCredential($domainUser, $DomainUserPassword)
                    New-UDInputAction -Content @(
                        New-UDRow -Columns {
                            New-UDColumn -Content {
                                New-UDTable -Title "VM Information:" -Headers @(" ", " ") -Endpoint{
                                    [PSCustomObject]@{
                                        'Computer Name' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                        'Operating System' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {(Get-CimInstance -ClassName Win32_OperatingSystem).Caption}
                                        'RDP Port Number' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials { Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object PortNumber} | Select-Object -ExpandProperty PortNumber;
                                        'Host Server' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials { Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object HostName} | Select-Object -ExpandProperty HostName;
                                        'IP Address(es)' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript {$_.IPAddress -ne '127.0.0.1'} | Sort-Object -Property InterfaceIndex | Select-Object -ExpandProperty IPAddress}
                                    }.GetEnumerator() | Out-UDTableData -Property @("Name","Value")
                                    New-UDButton -Text "RDP to Server" -Icon desktop -IconAlignment right -OnClick {
                                        $port = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials { Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object PortNumber} | Select-Object -ExpandProperty PortNumber;
                                        $pcName = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                        mstsc /v:"$pcName"`."$Domain"`:"$port"
                                    }
                                }
                            }
                            New-UDColumn -Content {
                                New-UDGrid -Title "Current Users" -Endpoint {
                                    $pcName = Invoke-Command -HideComputerName "$ServerName.$Domain" {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                    $users =@()
                                    $users = Get-TSSession -ComputerName $pcName | Where-Object {$_.UserName -ne ""} | Select-Object UserName,WindowStationName,State,LoginTime 
                                    $users | Out-UDGridData
                                }
                            }
                        }
                        New-UDRow -Columns {
                            New-UDColumn -Content {
                                $pcName = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                New-UDMonitor -Id "cpuLoad" -Title "Average CPU Load (%) for $pcName" -Label "Average CPU Load (%)" -Type Line -DataPointHistory 20 -RefreshInterval 3 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
                                    try {
                                        Get-WmiObject win32_processor -ComputerName "$pcName.$Domain" -Credential $Credentials | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average | Out-UDMonitorData
                                        }
                                    catch {
                                        0 | Out-UDMonitorData
                                    }
                                }
                            }
                            New-UDColumn -Content {
                                $pcName = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                New-UdChart -Title "Disk Space by Drive for $pcName" -Type Bar -AutoRefresh -Endpoint {
                                    Invoke-Command -HideComputerName "$pcName.$Domain" -Credential $Credentials {Get-CimInstance -ClassName Win32_LogicalDisk } | ForEach-Object {
                                            [PSCustomObject]@{ DeviceId = $_.DeviceID;
                                                               Size = [Math]::Round($_.Size / 1GB, 2);
                                                               FreeSpace = [Math]::Round($_.FreeSpace / 1GB, 2); } } | Out-UDChartData -LabelProperty "DeviceID" -Dataset @(
                                        New-UdChartDataset -DataProperty "Size" -Label "Total Size (GB)" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                                        New-UdChartDataset -DataProperty "FreeSpace" -Label "Free Space (GB)" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                                    )
                                } 
                            }
                        }
                    )
            }
        }
}
$Pages += New-UDPage -Name "Host Information" -Icon server -Content {
    New-UDColumn -SmallSize 3 -Content {
        New-UDInput -Title "Host Server Info" -Endpoint {
            param(
                [ValidateSet("TWCustomer.local")]$Domain,
                #[Parameter(Mandatory)]
                #[String]$DomainUserName,
                #[SecureString]$DomainUserPassword,
                #[Parameter(Mandatory)]
                [String]$HostName
                )
                #$domainUser = "$Domain\$DomainUserName"
                #$domainPassword = ConvertTo-SecureString $DomainUserPassword -AsPlainText -Force
                #$Credentials = New-Object System.Management.Automation.PSCredential($domainUser, $DomainUserPassword)
                New-UDInputAction -Content @(
                    New-UDRow -Columns {
                        New-UDColumn -Content {
                            New-UDTable -Title "Host Server Information:" -Headers @(" ", " ") -Endpoint{
                                [PSCustomObject]@{
                                    'Computer Name' = Invoke-Command -HideComputerName "$HostName.$Domain" {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                    'Operating System' = Invoke-Command -HideComputerName "$HostName.$Domain"{(Get-CimInstance -ClassName Win32_OperatingSystem).Caption}
                                    'Service Tag' = Get-WmiObject -ComputerName "$HostName.$Domain" -Class Win32_BIOS | Select-Object -Property SerialNumber | Select-Object -ExpandProperty SerialNumber
                                    #'RDP Port Number' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials { Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object PortNumber} | Select-Object -ExpandProperty PortNumber;
                                    #'Host Server' = Invoke-Command -HideComputerName "$ServerName.$Domain" -Credential $Credentials { Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object HostName} | Select-Object -ExpandProperty HostName;
                                    'IP Address(es)' = Invoke-Command -HideComputerName "$HostName.$Domain"{Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript {$_.IPAddress -ne '127.0.0.1'} | Sort-Object -Property InterfaceIndex | Select-Object -ExpandProperty IPAddress}
                                }.GetEnumerator() | Out-UDTableData -Property @("Name","Value")
                                New-UDButton -Text "RDP to Server" -Icon desktop -IconAlignment right -OnClick {
                                    $port = Invoke-Command -HideComputerName "$HostName.$Domain" { Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object PortNumber} | Select-Object -ExpandProperty PortNumber;
                                    $pcName = Invoke-Command -HideComputerName "$HostName.$Domain"  {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                                    mstsc /v:"$pcName"`."$Domain"`:"$port"
                                }
                            }
                        }
                        New-UDColumn -Content {
                            $pcName = Invoke-Command -HideComputerName "$HostName.$Domain" {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                            New-UDMonitor -Id "cpuLoad" -Title "Average CPU Load (%) for $pcName" -Label "Average CPU Load (%)" -Type Line -DataPointHistory 20 -RefreshInterval 3 -ChartBackgroundColor '#80FF6B63' -ChartBorderColor '#FFFF6B63'  -Endpoint {
                                try {
                                    Get-WmiObject win32_processor -ComputerName "$pcName.$Domain" | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average | Out-UDMonitorData
                                    }
                                catch {
                                    0 | Out-UDMonitorData
                                }
                            }
                        }
                        New-UDColumn -Content {
                            $pcName = Invoke-Command -HideComputerName "$HostName.$Domain" {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                            New-UdChart -Title "Disk Space by Drive for $pcName.$Domain" -Type Bar -AutoRefresh -Endpoint {
                                Invoke-Command -HideComputerName "$pcName.$Domain" {Get-CimInstance -ClassName Win32_LogicalDisk } | ForEach-Object {
                                        [PSCustomObject]@{ DeviceId = $_.DeviceID;
                                                           Size = [Math]::Round($_.Size / 1GB, 2);
                                                           FreeSpace = [Math]::Round($_.FreeSpace / 1GB, 2); } } | Out-UDChartData -LabelProperty "DeviceID" -Dataset @(
                                    New-UdChartDataset -DataProperty "Size" -Label "Total Size (GB)" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                                    New-UdChartDataset -DataProperty "FreeSpace" -Label "Free Space (GB)" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                                )
                            } 
                        }
                        # New-UDColumn -Content {
                        #     New-UDGrid -Title "Current VMs" -Endpoint {
                        #         $pcName = Invoke-Command -HideComputerName "$HostName.$Domain" {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object ComputerName} | Select-Object -ExpandProperty ComputerName;
                        #         $VMs =@()
                        #         $VMs = Get-VM -ComputerName "$pcName.$Domain" | Select-Object VMName,State,Version
                        #         #Invoke-Command -HideComputerName "$pcName.$Domain" {Get-VM | Select-Object VMName,State}
                        #         $VMs | Select-Object -ExcludeProperty RunspaceId, PSShowComputerName, PSComputerName | Out-UDGridData
                        #     }
                        # }
                    }
                )
        }
    }
}
# $Pages += New-UDPage -Name "Host VM Inventory" -Icon clipboard -Content {
#     New-UDGrid -Title "Inventory of VMs on Hosts" -Endpoint {
#         $serversOuPath ='OU=HV Host Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
#         $servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending
#         $out =@()
#         foreach($server in $servers)
#         {
#             $script = {
#                 Get-VM 
#             }
            
#             $out += Invoke-Command -HideComputerName $server -ScriptBlock $script
#         }
#         $out | Select-Object -Property VMName, State, ComputerName -ExcludeProperty RunspaceId, PSShowComputerName, PSComputerName | Out-UDGridData
#     }
# }


# #Command defining the dashboard, it's title and passing the theme and pages
# $Dashboard = 
New-UDDashboard -Title "Sidious - Control Center" -Pages $Pages #-LoginPage $LoginPage #-Theme $theme
#Command to actually Start the dashboard
# Start-UDDashboard -Dashboard ($Dashboard) -Port 10003 -AutoReload 