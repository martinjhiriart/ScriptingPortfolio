$FilePath = "\\hvneedlesshare1.needleshosted.local\NeedlesShare1\NeedlesCustomer1"
$FirmShares = Get-ChildItem -Path $FilePath 
$SharePathsArray = @()
foreach($Share in $FirmShares)
{
    $SharePathsArray += $Share.FullName
}
$ListOfCustomerFiles =@()
foreach($SharePath in $SharePathsArray)
{
    $CustomerFiles = Get-ChildItem -Path $SharePath -Recurse
    $ListOfCustomerFiles += $CustomerFiles.FullName
}
$ACLsToCheck =@()
foreach($CustomerFile in $ListOfCustomerFiles)
{
    $ACL = Get-Acl -LiteralPath $CustomerFile 
    $ACLsToCheck += $ACL
}
$ACLOutput = @()
foreach($ACLToCheck in $ACLsToCheck)
{
    $ACLTemplate = $ACLToCheck.Access | Where-Object {$_.IdentityReference -ne "NT AUTHORITY\SYSTEM"} | Where-Object {$_.IdentityReference -ne "BUILTIN\Administrators"} | Where-Object {$_.IdentityReference -ne "NEEDLESHOSTED\AdminHost"} | Where-Object {$_.IdentityReference -ne "CREATOR OWNER"}
    foreach($Entry in $ACLTemplate)
    {
        $NewAclObject = [PSCustomObject]@{
            FilePath = Convert-Path $ACLToCheck.Path
            FileSystemRights = $Entry.FileSystemRights.ToString()
            AccessControlType = $Entry.AccessControlType.ToString()
            IdentityReference = $Entry.IdentityReference.ToString()
            IsInherited = $Entry.IsInherited.ToString()
            InheritanceFlags = $Entry.InheritanceFlags.ToString()
            PropagationFlags = $Entry.PropagationFlags.ToString()
        }
        $ACLOutput += $NewAclObject
    }
    
}
#$ACLOutput
# $NewAclObject = [PSCustomObject]@{
#     FilePath = $ConvertedPath
#     FileSystemRights = $ACLTemplate.FileSystemRights.ToString()
#     AccessControlType = $ACLTemplate.AccessControlType.ToString()
#     IdentityReference = $ACLTemplate.IdentityReference.ToString()
#     IsInherited = $ACLTemplate.IsInherited.ToString()
#     InheritanceFlags = $ACLTemplate.InheritanceFlags.ToString()
#     PropagationFlags = $ACLTemplate.PropagationFlags.ToString()
# }
# $ACLOutput += $NewAclObject
$ACLOutput | Export-Excel -AutoSize -TableName NeedlesShare1ACLs -WorksheetName "Needles Share 1 ACLs" -Path "C:\Automation\NeedlesShare1ACLs.xlsx"