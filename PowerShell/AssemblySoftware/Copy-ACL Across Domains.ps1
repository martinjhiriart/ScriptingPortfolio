#$OldDomain = Read-Host "Enter Current Domain (e.g. GLF)"
$OldUserName = Read-Host "Enter Current UserName"
$NewUserName = Read-Host "Enter New UserName"
$OldIdentity = "<DOMAINNAME>\$OldUserName"
$NewIdentity = "<DOMAINNAME>\$NewUserName"
$filePath = #Path of files to get ACLs from
$test = Get-ACL -LiteralPath $filePath
$TWSupportTemplate = $test.Access | Where-Object{$_.IdentityReference -eq $OldIdentity}


$TestObject = [PSCustomObject]@{
    FileSystemRights = $TWSupportTemplate.FileSystemRights
    AccessControlType = $TWSupportTemplate.AccessControlType
    IdentityReference = $NewIdentity
    IsInherited = $TWSupportTemplate.IsInherited
    InheritanceFlags = $TWSupportTemplate.InheritanceFlags
    PropagationFlags = $TWSupportTemplate.PropagationFlags
}

$test.SetAccessRuleProtection($False, $False)

$newACL = New-Object System.Security.AccessControl.FileSystemAccessRule($TestObject.IdentityReference,$TestObject.FileSystemRights, $TestObject.InheritanceFlags, $TestObject.PropagationFlags, $TestObject.AccessControlType)
$test.AddAccessRule($newACL)
Set-Acl $filePath $test