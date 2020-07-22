$FileName = "EmployeeAudit-" + "$(Get-Date -Format MM-dd-yyyy)" + ".xlsx"
$FilePath = "<FILE PATH FOR RESULT>\" + $FileName
$FileCheck = Test-Path -Path $FilePath
if($FileCheck)
{
    Remove-Item $FilePath
}

    $InternalEmployees = Get-ADUser -SearchBase "<DISTINGUISHED NAME OF OU WHERE EMPLOYEE USERS ARE>" -Filter * | Select-Object Name, SamAccountName, Enabled
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
                GroupIsDomainAdmin = if($Group -eq "<DOMAINGROUPNAME1>" -or $Group -eq "<DOMAINGROUPNAME2>" -or $Group -eq "<DOMAINGROUPNAME3>")
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
    $AuditResults | Sort-Object EmployeeName | Export-Excel -Path $FilePath -AutoSize -TableName TWCustomerInternalEmployeeAudit -WorksheetName "Employee Audit" -ConditionalText $DomainAdmin,$DisabledAccounts