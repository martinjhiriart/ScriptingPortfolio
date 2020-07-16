function Revan{
    $CustomerFirstName = Read-Host "Enter User's First Name"
    $CustomerLastName = Read-Host "Enter User's Last Name"
    $CustomerFullName = $CustomerFirstName + " " +$CustomerLastName
    $CustomerADName = Read-Host "Enter User's AD Username"
    $CustomerPassword = Read-Host "Enter User's Password" -AsSecureString
    $CustomerGroupName = Read-Host "Enter Firm OU to create User in"
    $OUPath = "OU=" + $CustomerGroupName + ",OU=Customers,DC=TWCustomer,DC=local"
    $CustomerUPN = $CustomerADName+"@TWCustomer.local"
    New-ADUser -GivenName $CustomerFirstName -Surname $CustomerLastName -Name $CustomerFullName -SamAccountName $CustomerADName -AccountPassword $CustomerPassword -CannotChangePassword $true -PasswordNeverExpires $true -Path $OUPath -Enabled $true -UserPrincipalName $CustomerUPN
    
    Clear-Host
    Write-Host "User Created. Review Below."
    Get-ADUser -Identity $CustomerADName | Select-Object GivenName, Surname, SamAccountName, Enabled | Format-Table -AutoSize
    
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
            Sidious
        }
    }
}
#This function will ask the user if they would like to add an Active Directory user to a security group
function Revan_SecGroup{
    $CustomerSecGroupName = Read-Host "Please Enter the Security Group to add $CustomerADName to"
    $SecGroupCheck = Get-ADGroup -LDAPFilter "(SAMAccountName=$CustomerSecGroupName)"
    if($SecGroupCheck -ne $null)
    {
        Add-ADGroupMember -Identity $CustomerSecGroupName -Members $CustomerADName
    }
    else
    {
        Write-Warning "Security Group Doesn't Exist. Please Try Again."
        Pause
        Nihilus
    }
}