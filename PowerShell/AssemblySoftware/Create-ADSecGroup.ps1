function Sion {
    $CustomerOU = Read-Host 'Enter Customer OU'
    $OUPath = "OU=" + $CustomerOU + ",<DISTINGUISHED NAME FOR OU WHERE SECURITY GROUP WILL BE CREATED>"
    if(![adsi]::Exists("LDAP://$OUPath"))
    {
        Write-Warning "OU Doesn't Exist. Please Try Again."
        Pause
        Clear-Host
        Sion
    }
    else{
        $CustomerSecGroupName = Read-Host 'Enter New Security Group Name'
        $CustomerOUPath = "OU=" + $CustomerOU + ",<DISTINGUISHED NAME FOR OU WHERE SECURITY GROUP WILL BE CREATED>"
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