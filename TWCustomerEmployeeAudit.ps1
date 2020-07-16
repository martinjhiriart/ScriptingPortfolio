$csvName = "Employee Audit_" + "$(Get-Date -Format MM-dd-yyyy)" + ".csv"
$csvPath = "C:\Automation\Audit\" + $csvName
Get-ADUser -SearchBase "OU=RDPAdmins,OU=Corporate Users,DC=TWCustomer,DC=local" -Filter * | Select-Object Name, SamAccountName, Enabled | Export-Csv -Path $csvPath
$users = Import-Csv -Path $csvPath
foreach($user in $users)
{
    '------------------------------------'
    Write-Host "Full Name: " -NoNewline -ForegroundColor Magenta
    Write-Host $user.Name
    Write-Host "User Name: " -NoNewline -ForegroundColor Magenta 
    Write-Host $user.SamAccountName
    Write-Host "Enabled: " -NoNewline -ForegroundColor Cyan
    if($user.Enabled -eq "True")
    {
        Write-Host $user.Enabled -ForegroundColor Green
    }
    else
    {
        Write-Host $user.Enabled -ForegroundColor Red
    }
    Write-Host "Member of the following groups:" -ForegroundColor Yellow
    Get-ADPrincipalGroupMembership -Identity $user.SamAccountName | Select-Object -ExpandProperty Name
    ""
}
