function Test-UserGroup {
    $groups = Get-ADPrincipalGroupMembership -Identity $env:USERNAME | Select-Object -ExpandProperty name
    if($groups -like 'TWSupport')
    {
        Sheev
    }
    elseif ($groups -like  'TWHosting') {
        Write-Host "This is working"
    }
    else{
        Write-Error -Message "Access Denied" -Category AuthenticationError
        Pause
        Exit
    }
}
function Login {
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
function Sheev{
    Login
}
function Maul {
    Set-Location -LiteralPath 'C:\Program Files\WindowsPowerShell\Modules\Vader'
       do{
           Write-Host '========================' -ForegroundColor Cyan
           Write-Host 'Hosting Domain to Manage' -ForegroundColor Magenta
           Write-Host '========================' -ForegroundColor Cyan
           Write-Host '1 - TWCustomer.local'
           Write-Host '2 - NeedlesHosted.local'
           Write-Host '3 - CS.local'
           Write-Host '4 - GLF.local'
           Write-Host '5 - PEJ.local'
           Write-Host '6 - PWD.local'
           Write-Host '7 - RLG.local'
           Write-Host '8 - SLF.local'
           Write-Host '0 - Exit' -ForegroundColor Red
           Write-Host 'Select Domain: ' -NoNewline -ForegroundColor Yellow
           $domainChoice = Read-Host
           
           switch($domainChoice)
           {
               1{
                   $domain = 'TWCustomer.local'
                   Clear-Host
                   Tyranus
               }
               2{
                   $domain = 'NeedlesHosted.local'
                   Clear-Host
                   Tyranus
               }
               3{
                   $domain = 'CS.local'
                   Clear-Host
                   Tyranus
               }
               4{
                   $domain = 'GLF.local'
                   Clear-Host
                   Tyranus
               }
               5{
                    $domain = 'PEJ.local'
                    Clear-Host
                    Tyranus
               }
               6{
                    $domain = 'PWD.local'
                    Clear-Host
                    Tyranus
               }
               7{
                    $domain = 'RLG.local'
                    Clear-Host
                    Tyranus
               }
               8{
                   $domain = 'SLF.local'
                   Clear-Host
                   Tyranus
               }
           }
   
           
       }
       while ($domainChoice -ne '0')
       Set-Location '~'
       Clear-Host
   }
   function Tyranus {
    Set-Location -LiteralPath 'C:\Program Files\WindowsPowerShell\Modules\Sheev'
                Clear-Host
                Write-Host '==========================' -ForegroundColor Cyan
                Write-Host 'Remote Computer Management' -ForegroundColor Magenta
                Write-Host '==========================' -ForegroundColor Cyan
                Write-Host '1 - VM Manangement'
                Write-Host '0 - Exit to Menu' -ForegroundColor Red
                Write-Host 'Select:' -NoNewline -ForegroundColor Yellow
                $remoteInput = Read-Host 
                
                switch ($remoteInput) {
                    1 {
                        . .\RemoteManagement.ps1 $domain
                    }

                    0{
                        Clear-Host
                    }
                }
                
    Set-Location '~'
    Clear-Host
}