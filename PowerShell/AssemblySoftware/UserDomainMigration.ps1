$Users = Import-Csv -Path "<FILE PATH OF CSV TO IMPORT>"
$UserCredsArray =@()
function Generate-Password([int]$numChars = 16){
    return (-join ((65..90) + (97..122) + (49..57) + (35..38) + (63..64) + (33) | Get-Random -Count $numChars | % {[char]$_}))
}
foreach($User in $Users)
{
    $FirstName = $User.GivenName
    $LastName = $User.Surname
    $FullName = $User.Name
    $CustomerADName = $User.SamAccountName
    $Password = Generate-Password
    $SecureStringPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $GroupName = "CS"
    $OUPath = "OU=" + $GroupName + ",<DISTINGUISHED NAME OF OU WHERE SECURITY GROUP IS>"
    $UPN = $CustomerADName+"@<UPN SUFFIX>"
    New-ADUser -GivenName $FirstName -Surname $LastName -Name $FullName -SamAccountName $ADName -AccountPassword $SecureStringPassword -CannotChangePassword $true -PasswordNeverExpires $true -Path $OUPath -Enabled $true -UserPrincipalName $UPN
    
    $UserCreds = [PSCustomObject]@{ 
        ADUser = $ADName
        Password = $Password
    }
    $UserCredsArray += $UserCreds
 
}
$UserCredsArray | Export-Excel -AutoSize -TableName "<NEW TABLE NAME>" -WorksheetName "<NEW WORKSHEET NAME>" -Path "<FILE PATH FOR FINAL EXCEL SPREADSHEET>\NewCustomerIdentities.xlsx" -Show
