$rdsPort = Read-Host -Prompt "Please Enter the Port number for RDS."
New-ItemProperty -Path "HKLM\System\CurrentControlSet\Control\Terminal Services\WinStations\RDP-TCP\" -Name PortNumber -Value $rdsPort
New-NetFirewallRule -DisplayName "RDS Inbound TCP Port $rdsPort" -Direction inbound -localport $rdsPort -protocol TCP -action allow
Restart-Computer