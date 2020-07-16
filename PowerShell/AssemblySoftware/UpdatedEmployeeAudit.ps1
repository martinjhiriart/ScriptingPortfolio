$FileName = "EmployeeAudit-" + "$(Get-Date -Format MM-dd-yyyy)" + ".xlsx"
$FilePath = "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\" + $FileName
$FileCheck = Test-Path -Path $FilePath
if($FileCheck)
{
    Remove-Item $FilePath
}

    $InternalEmployees = Get-ADUser -SearchBase "OU=RDPAdmins,OU=Corporate Users,DC=TWCustomer,DC=local" -Filter * | Select-Object Name, SamAccountName, Enabled
    $AuditResults = @()
    $DisabledAccounts = New-ConditionalText -Text "FALSE" -Range "C:C"
    $DomainAdmin = New-ConditionalText -Text "TRUE" -Range "E:E" -ConditionalTextColor DarkGreen -BackgroundColor LightGreen
    foreach($Employee in $InternalEmployees)
    {
        $Groups =  Get-ADPrincipalGroupMembership -Identity $Employee.SamAccountName | Select-Object -ExpandProperty Name
        foreach($Group in $Groups)
        {            
            $AuditObject = [PSCustomObject]@{
                EmployeeName = $Employee.Name
                ADUserName = $Employee.SamAccountName
                Enabled = $Employee.Enabled
                Group = $Group
                GroupIsDomainAdmin = if($Group -eq "TWAdmins" -or $Group -eq "TWServiceAccounts" -or $Group -eq "TWHosting")
                {
                    $true
                }
                else {
                    $false
                }
            }
            $AuditResults += $AuditObject
        }
    }
    $AuditResults | Sort-Object EmployeeName | Export-Excel -Path $FilePath -AutoSize -TableName TWCustomerInternalEmployeeAudit -WorksheetName "TWC Employee Audit" -ConditionalText $DomainAdmin,$DisabledAccounts #-IncludePivotTable -PivotRows = "EmployeeName" #-PivotData = 'ADUserName' -PivotFilter = 'Group'
