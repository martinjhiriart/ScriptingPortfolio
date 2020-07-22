#This is a cross-domain management utility developed by Martin Hiriart in order to help manage the Assembly Software LLC Hosted Environment
function Execute-Order66 {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("Active Directory","Auditing","Management","Exit")]$ConsoleType
    )
    if($ConsoleType -eq "Active Directory")
    {
        Clear-Host
        Vader
    }
    elseif($ConsoleType -eq "Auditing")
    {
        Clear-Host
        Tyranus
    }
    elseif($ConsoleType -eq "Management")
    {
        Clear-Host
        Server_Select
    }
    else{
        exit
    }
    
}
#This function just prompts the user for the type of server and then routes them to the appropriate management console
function Server_Select {
    Write-Host '==================' -ForegroundColor Magenta
    Write-Host 'Select Server Type' -ForegroundColor Cyan
    Write-Host '==================' -ForegroundColor Magenta
    Write-Host '1 - Virtual' -ForegroundColor Yellow
    Write-Host '2 - Physical' -ForegroundColor Yellow
    Write-Host '0 - Exit to Main Menu' -ForegroundColor Red
    $ServerType = Read-Host 'Select'
    switch($ServerType)
    {
        1{
            Clear-Host
            Maul_Virtual_Login
        }
        2{
            Clear-Host
            Maul_Physical
        }
        Default{
            Clear-Host
            Execute-Order66
        }
    }
}
#This function allows the user to type in the domain and credentials in order to access information on a given server
function Maul_Virtual_Login {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("<LIST OF VALID DOMAINS")]$Domain,
        [Parameter(Mandatory)]
        [String]$UserName,
        [Parameter(Mandatory)]
        [securestring]$Password
    )
    Maul_Virtual
}
#This function runs various queries against the target virtual machine to provide the user with useful information
function Maul_Virtual {
    #Parameter asking for the name of the target machine to run the queries against
    param(
        [Parameter(Mandatory)]
        [String]$Virtual_ServerName
    )
    $FQDN = "$Virtual_ServerName`.$Domain"
    $Virtal_ServerCheck = Test-NetConnection -ComputerName $FQDN -CommonTCPPort WINRM | Select-Object -ExpandProperty TCPTestSucceeded
    if($Virtal_ServerCheck -eq $false)
    {
        Write-Warning -Message "Cannot Establish Connection to $Virtual_ServerName. Please Try Again"
        Pause
        Maul_Virtual
    }
    else
    {
        $DomainUser = $Domain+'\'+$UserName
        $DomainCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $Password
        #Query to pull RDP Port from registry
        $RDP_Port = Invoke-Command -HideComputerName $FQDN -Credential $DomainCredentials {Get-ItemProperty  -Path HKLM:\SYSTEM\CurrentControlSet\Control\Termin*Server\WinStations\RDP*CP\ -Name PortNumber | Select-Object -ExpandProperty PortNumber}
        #Query to pull the IP Address/Addresses the target machine has
        $IP_Address = Invoke-Command -ComputerName $FQDN -Credential $DomainCredentials {Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript {$_.IPAddress -ne '127.0.0.1'} | Sort-Object -Property InterfaceIndex | Select-Object -ExpandProperty IPAddress}
        #Query to pull Disks connected to target machine and calculate the free disk space and total disk space
        $Disks = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2" -ComputerName $FQDN -Credential $DomainCredentials
        $Disks_Sizes = foreach($Disk in $Disks)
        {
            if($Disk.Size -gt 0)
            {
                $Size = [System.Math]::Round($Disk.Size/1GB,2)
                $Free = [System.Math]::Round($Disk.FreeSpace/1GB,2)
                $Total = ($Free/$Size)
                $Baseline = 0.05
                if($total -lt $Baseline)
                {
                    "`n`tDrive",$Disk.Name, "{0:N2} GB" -f $Free
                }
                else
                {
                    "`n`tDrive",$Disk.Name, "{0:N2} GB" -f $Free
                }
            }
        }
        #Query that pulls the Hyper-V host of the target VM
        $Host_Server = Invoke-Command -ComputerName $FQDN -Credential $DomainCredentials {Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Virtual` Machine\Guest\Parameters\ -Name HostName | Select-Object -ExpandProperty HostName}
        #Query that pulls a snapshot of the users currently signed into the target machine
        $CurrentUsers = Invoke-Command -ComputerName $FQDN -Credential $DomainCredentials {query user}
        #Query that checks the current installed version of .NET Framework on the target VM
        $ReleaseVersion = Invoke-Command -HideComputerName $FQDN -Credential $DomainCredentials {(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release}
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
        #Query that pulls the version of the operating system currently installed on the virtual machine
        $Virtual_Server_OS = Get-WmiObject -Computer $FQDN -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        #Formatted output of all the above queries
        Write-Host ''
        Write-Host '============================' -ForegroundColor Magenta
        Write-Host 'Virtual Machine Information' -ForegroundColor Cyan
        Write-Host '============================' -ForegroundColor Magenta
        Write-Host 'Computer Name: ' -NoNewline -ForegroundColor Yellow
        Write-Host $FQDN
        Write-Host 'Operating System:' -ForegroundColor Yellow
        Write-Host $Virtual_Server_OS
        Write-Host '.NET Framework Version:' -ForegroundColor Yellow
        Write-Host $NETFrameworkVersion
        Write-Host 'RDP Port Number: ' -NoNewline -ForegroundColor Yellow
        Write-Output $RDP_Port
        Write-Host 'Free Disk Space: ' -NoNewline -ForegroundColor Yellow
        Write-Host $Disks_Sizes
        Write-Host 'Host Server: ' -NoNewline -ForegroundColor Yellow
        Write-Host $Host_Server -ForegroundColor Green
        Write-Host 'IP Address(es): ' -ForegroundColor Yellow
        Write-Output $IP_Address
        Write-Host 'Current Users' -ForegroundColor Yellow
        Write-Output $CurrentUsers
        Write-Host '____________________________' -ForegroundColor Magenta
        Write-Host ' '
        #Asks user if he/she would like to access the Management console in order to access more management features
        Write-Host 'Access Management Console?' -NoNewline -ForegroundColor Yellow
        Write-Host '(Y/N): ' -NoNewline
        $VirtMgmt = Read-Host
        switch ($VirtMgmt) 
        {
            'Y'{
                Maul_Virtual_Management
            }
            Default {
                Pause
                Clear-Host
                Execute-Order66
            }
        }
    }
}
#This function provides the "Advanced Management Console" for the specified virtual machine.
#This allows the user to have additional management capabilities beyond just viewing the information on the server
function Maul_Virtual_Management {
    Write-Host '=================================' -ForegroundColor Magenta
    Write-Host 'Virtual Server Management Console' -ForegroundColor Cyan
    Write-Host '=================================' -ForegroundColor Magenta
    Write-Host '1 - RDP Connect to Server' -ForegroundColor Yellow
    Write-Host '0 - Exit to Main Menu' -ForegroundColor Red
    $VirtMgmt_Console = Read-Host 'Select'

    switch($VirtMgmt_Console)
    {
        1{
            mstsc /v:$FQDN`:$RDP_Port
            Clear-Host
            Maul_Virtual_Management
        }
        Default{
            Pause
            Clear-Host
            Execute-Order66
        }
    }
}
#This function rns various queries against the target physical server in order to provide the user with useful information
function Maul_Physical {
    param(
        [Parameter(Mandatory)]
        [string]$Physical_ServerName
    )
    $Physical_ServerCheck = Test-NetConnection -ComputerName $Physical_ServerName -CommonTCPPort WINRM | Select-Object -ExpandProperty TCPTestSucceeded
    if($Physical_ServerCheck -eq $false)
    {
        Write-Error -Message "Cannot Establish Connection to $Physical_ServerName. Please Try Again"
        Pause
        Maul_Physical
    }
    else
    {
        $Physical_IP_Address = Invoke-Command -ComputerName $Physical_ServerName {Get-NetIPAddress -AddressFamily IPv4 | Where-Object -FilterScript {$_.IPAddress -ne '127.0.0.1'} | Sort-Object -Property InterfaceIndex | Select-Object -ExpandProperty IPAddress}
        $Physical_Server_Disks = Get-WmiObject -Class "Win32_LogicalDisk" -Namespace "root\CIMV2" -ComputerName $Physical_ServerName
        $Physical_Disk_Results = foreach($Physical_Disk in $Physical_Server_Disks)
        {
            if($Physical_Disk.Size -gt 0)
            {
                $Physical_Size = [System.Math]::Round($Physical_Disk.Size/1GB,2)
                $Physical_Free = [System.Math]::Round($Physical_Disk.FreeSpace/1GB,2)
                $Physical_Total = ($Physical_Free/$Physical_Size)
                $Baseline = 0.05
                if($Physical_Total -lt $Baseline)
                {
                    "`n`tDrive",$Physical_Disk.Name, "{0:N2} GB" -f $Physical_Free
                }
                else
                {
                    "`n`tDrive",$Physical_Disk.Name, "{0:N2} GB" -f $Physical_Free
                }
            }
        }
        $Hyper_V_VMs = Invoke-Command -ComputerName $Physical_ServerName {Get-VM | Where-Object {$_.State -eq 'Running'} | Select-Object -ExpandProperty VMName}
        $Physical_Server_Memory = Invoke-Command -ComputerName $Physical_ServerName {Get-WmiObject Win32_OperatingSystem -Property FreePhysicalMemory | Select-Object -ExpandProperty FreePhysicalMemory}
        $Physical_Server_FreeMemory = "`t{0} GB" -f ([math]::round(($Physical_Server_Memory / 1024 /1024), 2))
        $Physical_Server_ServiceTag = Get-WmiObject -ComputerName $Physical_ServerName -Class Win32_BIOS | Select-Object -ExpandProperty SerialNumber
        $Manufacturer = Get-WmiObject -ComputerName $Physical_ServerName Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
        $Physical_ServerDomain = Invoke-Command -ComputerName $Physical_ServerName {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\ -Name Domain | Select-Object -ExpandProperty Domain}
        $Physical_Server_Name = Invoke-Command -ComputerName $Physical_ServerName {Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\ -Name Computername | Select-Object -ExpandProperty ComputerName}
        $Physical_Server_FQDN = "$Physical_Server_Name`.$Physical_ServerDomain"
        $Physical_Server_OS = Get-WmiObject -Computer $Physical_ServerName -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption
        $PhysicalServerReleaseVersion = Invoke-Command -HideComputerName $Physical_ServerName {(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release}
        if($PhysicalServerReleaseVersion -ge 378389)
        {
            $Physical_NETFrameworkVersion = "4.5"
        }
        if($PhysicalServerReleaseVersion -ge 378675)
        {
            $Physical_NETFrameworkVersion = "4.5.1"
        }
        if($PhysicalServerReleaseVersion -ge 379893)
        {
            $Physical_NETFrameworkVersion = "4.5.2"
        }
        if($PhysicalServerReleaseVersion -ge 393295)
        {
            $Physical_NETFrameworkVersion = "4.6"
        }
        if($PhysicalServerReleaseVersion -ge 394254)
        {
            $Physical_NETFrameworkVersion = "4.6.1"
        }
        if($PhysicalServerReleaseVersion -ge 394802)
        {
            $Physical_NETFrameworkVersion = "4.6.2"
        }
        if($PhysicalServerReleaseVersion -ge 460798)
        {
            $Physical_NETFrameworkVersion = "4.7"
        }
        if($PhysicalServerReleaseVersion -ge 461308)
        {
            $Physical_NETFrameworkVersion = "4.7.1"
        } 
        if($PhysicalServerReleaseVersion -ge 461808)
        {
            $Physical_NETFrameworkVersion = "4.7.2"
        }
        if($PhysicalServerReleaseVersion -ge 528040)
        {
            $Physical_NETFrameworkVersion = "4.8 or later"
        }
        elseif($PhysicalServerReleaseVersion -lt 378389) {
            Write-Error ".NET Framework 4.5 or later not installed."
        }
        Write-Host ' '
        Write-Host '===========================' -ForegroundColor Magenta
        Write-Host 'Physical Server Information' -ForegroundColor Cyan
        Write-Host '===========================' -ForegroundColor Magenta
        Write-Host 'Computer Name: ' -NoNewline -ForegroundColor Yellow
        Write-Host $Physical_Server_FQDN
        Write-Host 'Manufacturer: ' -NoNewline -ForegroundColor Yellow
        Write-Host $Manufacturer -ForegroundColor Green
        Write-Host 'Service Tag: ' -NoNewline -ForegroundColor Yellow
        Write-Host $Physical_Server_ServiceTag -ForegroundColor Green
        Write-Host 'Operating System: ' -ForegroundColor Yellow
        Write-Host $Physical_Server_OS -ForegroundColor Green
        Write-Host '.NET Framework Version Installed:' -ForegroundColor Yellow
        Write-Host $Physical_NETFrameworkVersion
        Write-Host 'IP Address(es):' -ForegroundColor Yellow
        Write-Output $Physical_IP_Address
        Write-Host '=========================' -ForegroundColor Magenta
        Write-Host 'Host Resource Information' -ForegroundColor Cyan
        Write-Host '=========================' -ForegroundColor Magenta
        Write-Host 'Free Disk Space: ' -NoNewline -ForegroundColor Yellow 
        Write-Host $Physical_Disk_Results
        Write-Host ''
        Write-Host 'Available Memory:' -ForegroundColor Yellow
        Write-Output $Physical_Server_FreeMemory
        Write-Host ''
        Write-Host '===================' -ForegroundColor Magenta
        Write-Host 'Hyper-V Information' -ForegroundColor Cyan
        Write-Host '===================' -ForegroundColor Magenta
        Write-Host 'Current VMs:' -ForegroundColor Yellow
        Write-Output $Hyper_V_VMs
        Write-Host '___________________' -ForegroundColor Magenta
        Write-Host ' '
        Write-Host 'Access Management Console?' -NoNewline -ForegroundColor Yellow
        Write-Host '(Y/N): ' -NoNewline
        $PhysMgmt = Read-Host
        switch ($PhysMgmt) 
        {
            'Y'{
                Maul_Physical_Management
            }
            Default {
                Pause
                Clear-Host
                Execute-Order66
            }
        }
    }
}
#This function provides the "Advanced Management Console" for the specified physical machine.
#This allows the user to have additional management capabilities beyond just viewing the information on the server
function Maul_Physical_Management {
    Write-Host '==================================' -ForegroundColor Magenta
    Write-Host 'Physical Server Management Console' -ForegroundColor Cyan
    Write-Host '==================================' -ForegroundColor Magenta
    Write-Host '1 - Connect to Management Interface' -ForegroundColor Yellow
    Write-Host '2 - RDP Connect to Server' -ForegroundColor Yellow
    Write-Host '0 - Exit to Main Menu' -ForegroundColor Red
    $PhysMgmt_Console = Read-Host 'Select'
    switch($PhysMgmt_Console)
    {
        1{
            if($Manufacturer -eq 'Dell Inc.')
            {
                $URL = "https://" + $Physical_ServerName + ":1311"
            }
            elseif($Manufacturer -eq 'Supermicro')
            {
                $URL = "https://" + $Physical_ServerName + ":8444"
            }
            Start-Process -FilePath $URL
            Maul_Physical_Management
        }
        2{
            mstsc /v:$Physical_Server_FQDN
            Maul_Physical_Management
        }
        Default{
            Pause
            Clear-Host
            Execute-Order66
        }
    }
}
#This function allows the user to send an email from the Sidious management console
function Malgus{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$ToAddress,
        [Parameter(Mandatory)]
        [String]$Subject,
        [Parameter(Mandatory)]
        [String]$Message,
        [Parameter(Mandatory)]
        [ValidateSet("Yes","No")]$AddAttachment
    )
    $FromAddress = "<FROM ADDRESS>"
    $SMTP_Server = "<SMTP SERVER"
    $SMTP_Port = "<SMTP PORT>"
    if($AddAttachment -eq "Yes")
    {
        $AttachmentPath = Read-Host "Enter Path to File to Attach"
        Send-MailMessage -SmtpServer $SMTP_Server -Port $SMTP_Port -From $FromAddress -To $ToAddress -Subject $Subject -BodyAsHtml $Message -Attachments $AttachmentPath
    }
    else 
    {
        Send-MailMessage -SmtpServer $SMTP_Server -Port $SMTP_Port -From $FromAddress -To $ToAddress -Subject $Subject -BodyAsHtml -$Message
    }
    Pause
    Tyranus
}
#This function provides a comprehensive audit of the manufacturers of the physical servers in the environment
function Krayt {
    $serversOuPath ='<DISTINGUISHED NAME OF OU WITH PHYSICAL SERVERS>'
    $servers = Get-ADComputer -SearchBase $serversOuPath -Filter * | Select-Object -ExpandProperty Name

    $superMicros = @()
    $dells = @()
    $failures = @()
    $superMicroInfo =@()
    $dellInfo = @()
    $allServers =@()
    foreach($server in $servers)
    {
        $manufacturer = Get-WmiObject -ComputerName $server Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer
        if($manufacturer -eq 'Supermicro')
        {
            $superMicros += $server
        }
        elseif($manufacturer -eq 'Dell Inc.')
        {
            $dells += $server
        }
        else{
            $failures += $server
        }

    }

    foreach ($supermicro in $superMicros)
    {
        $superMicroInfo += Get-WmiObject -ComputerName $supermicro Win32_ComputerSystem | Select-Object Name, Manufacturer, Model 
    }
    foreach ($dell in $dells)
    {
        $dellInfo += Get-WmiObject -ComputerName $dell Win32_ComputerSystem | Select-Object Name, Manufacturer, Model
    }
    $allServers = $dellInfo + $superMicroInfo | Sort-Object -Property Name
    $allServers | Export-Excel -AutoSize -TableName "PhysicalServerAudit" -WorksheetName "Physical Servers by OEM" -Path "<FILE PATH FOR REPORT>\PhysicalServersByOEM.xlsx" 
    $failures | Out-File -FilePath "<FILE PATH FOR REPORT>\PhysicalServerRPCFailures.txt"
    $CountOfDells = ($dells).count
    $CountofSuperMicros = ($superMicros).count
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host "Physical Server Audit Complete" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Magenta
    Write-Host "Number of Dell Servers: " -NoNewline -ForegroundColor Yellow
    Write-Host $CountOfDells
    Write-Host "Number of SuperMicro Servers: " -NoNewline -ForegroundColor Yellow
    Write-Host $CountofSuperMicros
    Write-Host "Would you like to view the CSV with all the servers?" -NoNewline -ForegroundColor Yellow
    $ViewServerCSV = Read-Host "(Y/N)"
    switch($ViewServerCSV)
    {
        "Y"{
            Start-Process -FilePath "<FILE PATH FOR REPORT>\PhysicalServers.csv"
            Pause
            Tyranus
        }
        Default{
            Pause
            Clear-Host
            Tyranus
        }
    }
}
#This function serves as the "Auditing Console" which allows the user to run tasks that help collect information about the environment
function Tyranus {
    Write-Host '========================' -ForegroundColor Magenta
    Write-Host 'Hosting Auditing Console' -ForegroundColor Cyan
    Write-Host '========================' -ForegroundColor Magenta
    Write-Host '1 - Run Host VM Inventory Report' -ForegroundColor Yellow
    Write-Host '2 - Get List of Servers Based on Manufacturer' -ForegroundColor Yellow
    Write-Host '3 - Send Email from PowerShell' -ForegroundColor Yellow
    Write-Host '0 - Exit to Main Menu' -ForegroundColor Red
    $Audit_Console = Read-Host "Select"
    
    switch($Audit_Console)
    {
        1{
            $Physical_ServersOuPath ='<DISTINGUISHED NAME OF OU WITH PHYSICAL SERVERS>'
            $Physical_Servers = Get-ADComputer -SearchBase $Physical_ServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object -Descending
            $InventoryReport_FilePath = "<FILE PATH FOR REPORT>\HostVMInventoryReport-" + "$(Get-Date -f MM-dd-yyyy)"+ ".csv"
            $CheckForFile = Test-Path -Path $InventoryReport_FilePath
            if($CheckForFile -eq $true)
            {
                Clear-Content -LiteralPath $InventoryReport_FilePath
            } 
            foreach ($Physical_Server in $Physical_Servers) {
                Invoke-Command -HideComputerName $Physical_Server {Get-VM | Where-Object {($_.Name -notlike "*-*OFF")} | Select-Object Name,State,PSComputerName} | Select-Object Name,State,PSComputerName | Select-Object -ExcludeProperty RunspaceId,PSShowComputerName | Export-Csv -NoTypeInformation -Append -Path $InventoryReport_FilePath 
            }
        
            $uri = "<TEAMS URI FOR INCMOING WEBHOOK>"
            $body = ConvertTo-JSON @{
            text = 'Host-VM Inventory Report Completed for ' + $(Get-Date)
            }
            Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
        }
        2{
            Krayt
        }
        3{
            Malgus
        }
        Default {
            Clear-Host
            Execute-Order66
        }
    }
}
#This function allows the user to create a new Organizational Unit in Active Directory for a given customer
function Malak {
    Read-Host 'Enter Customer Name'
    $NewCustomerOUName = Read-Host
    New-ADOrganizationalUnit -Name $NewCustomerOUName -Path "<DISTINGUISHED NAME FOR NEW OU>"
    $DisabledUsersOUPath = "OU=DisabledUsers,OU=" + $NewCustomerOUName + ",<DISTINGUISHED NAME FOR NEW DISABLEDUSERS OU>"
    #Creates DisabledUsers OU within the newly created OU so we have a default location to move disabled users to if if does not already exist.
    if(![adsi]::Exists("LDAP://$DisabledUsersOUPath"))
    {
    $NewCustomerOUPath = "OU=" + $NewCustomerOUName + "<DISTINGUISHED NAME FOR NEW OU>"
    New-ADOrganizationalUnit -Name "DisabledUsers" -Path $NewCustomerOUPath
    }
    else
    {
        #Asks the user if they would like to create another OU for a different customer
        Write-Host "Create Another OU? " -NoNewline -ForegroundColor Yellow
        $AdditionalOU_Response = Read-Host "(Y/N)"

        switch($AdditionalOU_Response)
        {
            'Y'{
                Clear-Host
                Malak
            }
            Default{
                Clear-Host
                Vader
            }
        }
    }
}
#This function allows the user to create a new security group within a given customer's OU in AD
function Sion {
    $CustomerOU = Read-Host 'Enter Customer OU'
    $CustomerOUPath = "OU=" + $CustomerOU + ",<DISTINGUISHED NAME FOR NEW SECURITY GROUP IN OU>"
    #This if statement checks if the entered OU exists
    if(![adsi]::Exists("LDAP://$CustomerOUPath"))
    {
        Write-Warning "OU Doesn't Exist. Please Try Again."
        Pause
        Clear-Host
        Sion
    }
    else{
        $CustomerSecGroupName = Read-Host 'Enter New Security Group Name'
        New-ADGroup -Name $CustomerSecGroupName -SamAccountName $CustomerSecGroupName -GroupCategory Security -GroupScope Global -DisplayName $CustomerSecGroupName -Path $CustomerOUPath
    }

    Write-Host "Create Another Security Group?" -NoNewline -ForegroundColor Yellow
    $SecGroup_Response = "(Y/N)"

    switch($SecGroup_Response)
    {
        'Y'{
            Clear-Host
            Sion
        }
        Default{
            Clear-Host
            Vader
        }
    }
}
#This function allows the user to create a new user account in Active Directory
function Revan {
    $CustomerFirstName = Read-Host "Enter User's First Name"
    $CustomerLastName = Read-Host "Enter User's Last Name"
    $CustomerFullName = $CustomerFirstName + " " +$CustomerLastName
    $CustomerADName = Read-Host "Enter User's AD Username"
    $CustomerPassword = Read-Host "Enter User's Password" -AsSecureString
    $CustomerGroupName = Read-Host "Enter Firm OU to create User in"
    $OUPath = "OU=" + $CustomerGroupName + ",<DISTINGUISHED NAME FOR OU>"
    $CustomerUPN = $CustomerADName+"@<UPN SUFFIX>"
    New-ADUser -GivenName $CustomerFirstName -Surname $CustomerLastName -Name $CustomerFullName -SamAccountName $CustomerADName -AccountPassword $CustomerPassword -CannotChangePassword $true -PasswordNeverExpires $true -Path $OUPath -Enabled $true -UserPrincipalName $CustomerUPN
    
    Clear-Host
    Write-Host "User Created. Review Below."
    Get-ADUser -Identity $CustomerADName | Select-Object GivenName, Surname, SamAccountName, Enabled | Format-Table -AutoSize
    Pause
    #Asking the user if they would like to add the newly created user to a security group in AD
    Write-Host "Add User to Security Group? " -NoNewline -ForegroundColor Yellow
    $AddtoGroup = Read-Host "(Y/N)"
    switch ($AddtoGroup) 
    {
        'Y'{
            Clear-Host
            Get-ADUser -Identity $CustomerADName | Select-Object GivenName, Surname, SamAccountName, Enabled | Format-Table -AutoSize
            Revan_SecGroup
        }
        Default{
            Clear-Host
            Get-ADUser -Identity $CustomerADName | Select-Object GivenName, Surname, SamAccountName, Enabled | Format-Table -AutoSize
            Pause
            Vader
        }
    }
}
#This function will allow the user to add an Active Directory user to a security group
function Revan_SecGroup {
    $CustomerSecGroupName = Read-Host "Please Enter the Security Group to add $CustomerADName to"
    $SecGroupCheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$CustomerSecGroupName)"
    if($null -ne $SecGroupCheck)
    {
        Add-ADGroupMember -Identity $CustomerSecGroupName -Members $CustomerADName
        Pause
        Vader
    }
    else
    {
        Write-Warning "Security Group Doesn't Exist. Please Try Again."
        Pause
        Revan_SecGroup
    }
}
#This function allows the user to add any AD user account to a security group in AD
function Nihilus {
    $CustomerSamAccountName = Read-Host "Please Enter the AD Username of the Target User."
    $CustSecGroupName = Read-Host "Please Enter the Security Group to add $CustomerSamAccountName to"
    $SecGroupExistsCheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$CustSecGroupName)"
    if($null -ne $SecGroupExistsCheck)
    {
        Add-ADGroupMember -Identity $CustSecGroupName -Members $CustomerSamAccountName
        Pause
        Vader
    }
    else
    {
        Write-Warning "Security Group Doesn't Exist. Please Try Again."
        Pause
        Revan_SecGroup
    }
}
#This function serves as the "Active Directory Console" for the user to perform various tasks for Active Directory Management
function Vader {
    Write-Host '========================' -ForegroundColor Magenta
    Write-Host 'Active Directory Console' -ForegroundColor Cyan
    Write-Host '========================' -ForegroundColor Magenta
    Write-Host '1 - Create New Customer OU' -ForegroundColor Yellow
    Write-Host '2 - Create New Security Group for Customer' -ForegroundColor Yellow
    Write-Host '3 - Create New AD User' -ForegroundColor Yellow
    Write-Host '4 - Add User to Specific Security Group' -ForegroundColor Yellow
    Write-Host '5 - Check Group Membership for User' -ForegroundColor Yellow
    Write-Host '0 - Exit to Main Menu' -ForegroundColor Red
    $AD_Console = Read-Host "Select"

    switch($AD_Console)
    {
        1{
            Malak
        }
        2{
            Sion
        }
        3{
            Revan
        }
        4{
            Nihilus
        }
        5{

        }
        Default{
            Clear-Host
            Execute-Order66
        }
    }
}