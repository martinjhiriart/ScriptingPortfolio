$userSecurityGroup
function Test-UserGroup {
    $groups = Get-ADPrincipalGroupMembership -Identity $env:USERNAME | Select-Object -ExpandProperty name
    if($groups -like '<AD GROUP 1>')
    {
        "<FUNCTION OR CODE>"
    }
    elseif ($groups -like  '<AD GROUP 2>') {
        "<FUNCTION OR CODE>"
    }
    else{
        Write-Error -Message "Access Denied" -Category AuthenticationError
        Pause
        Exit
    }
}
function Check-UserPermission {
    #Checks to see if the current PowerShell session is elevated or not
    $admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if(!$admin)
    {
        #Calls the Test-UserGroup function to validate user's ability to use the script
        Test-UserGroup
    }
    else{
        #Denies access to the user if the PowerShell session is elevated (i.e. Run as Administrator)
        Write-Error -Message "Cannot Run in Elevated Shell" -Category AuthenticationError
    }
}

