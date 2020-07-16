function Sion {
    $CustomerOU = Read-Host 'Enter Customer OU'
    $OUPath = "OU=" + $CustomerOU + ",OU=Customers,DC=TWCustomer,DC=local"
    if(![adsi]::Exists("LDAP://$OUPath"))
    {
        Write-Warning "OU Doesn't Exist. Please Try Again."
        Pause
        Clear-Host
        Sion
    }
    else{
        $CustomerSecGroupName = Read-Host 'Enter New Security Group Name'
        $CustomerOUPath = "OU=" + $CustomerOU + ",OU=Customers,DC=TWCustomer,DC=local"
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