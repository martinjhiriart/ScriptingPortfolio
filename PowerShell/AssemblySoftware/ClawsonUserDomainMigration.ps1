$ClawsonUsers = Import-Csv -Path "C:\Users\twmartin\Desktop\ClawsonActiveUsers.csv"
$UserCredsArray =@()
function Generate-Password([int]$numChars = 16){
    return (-join ((65..90) + (97..122) + (49..57) + (35..38) + (63..64) + (33) | Get-Random -Count $numChars | % {[char]$_}))
}
foreach($CSUser in $ClawsonUsers)
{
    $CustomerFirstName = $CSUser.GivenName
    $CustomerLastName = $CSUser.Surname
    $CustomerFullName = $CSUser.Name
    $CustomerADName = $CSUser.SamAccountName
    $CustomerPassword = Generate-Password
    $CustomerSecureStringPassword = ConvertTo-SecureString $CustomerPassword -AsPlainText -Force
    $CustomerGroupName = "CS"
    $OUPath = "OU=" + $CustomerGroupName + ",OU=Customers,DC=TWCustomer,DC=local"
    $CustomerUPN = $CustomerADName+"@TWCustomer.local"
    New-ADUser -GivenName $CustomerFirstName -Surname $CustomerLastName -Name $CustomerFullName -SamAccountName $CustomerADName -AccountPassword $CustomerSecureStringPassword -CannotChangePassword $true -PasswordNeverExpires $true -Path $OUPath -Enabled $true -UserPrincipalName $CustomerUPN
    
    $UserCreds = [PSCustomObject]@{
        ADUser = $CustomerADName
        Password = $CustomerPassword
    }
    $UserCredsArray += $UserCreds

}
$UserCredsArray | Export-Excel -AutoSize -TableName "TWCNewUsers" -WorksheetName "CS TWC Users" -Path "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\ClawsonTWCustomerIdentities.xlsx" -Show
