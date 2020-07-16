function Transfer-UserAcl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory =$true)]
        [String]$OriginalIdentity,
        [Parameter(Mandatory=$true)]
        [String]$NewIdentity,
        [Parameter(Mandatory=$true)]
        [String]$FilePath
    )
    $ACL = Get-Acl -LiteralPath $FilePath
    $IdentityTemplate = $ACL.Access | Where-Object {$_.IdentityReference -eq $OriginalIdentity}

    $NewAclObject = [PSCustomObject]@{
        FileSystemRights = $IdentityTemplate.FileSystemRights
        AccessControlType = $IdentityTemplate.AccessControlType
        IdentityReference = $NewIdentity
        IsInherited = $IdentityTemplate.IsInherited
        InheritanceFlags = $IdentityTemplate.InheritanceFlags
        PropagationFlags = $IdentityTemplate.PropagationFlags
    }

    #$ACL.SetAccessRuleProtection($false,$false)

    $NewAclRule = New-Object System.Security.AccessControl.FileSystemAccessRule($NewAclObject.IdentityReference,$NewAclObject.FileSystemRights,$NewAclObject.InheritanceFlags,$NewAclObject.PropagationFlags,$NewAclObject.AccessControlType)
    $ACL.AddAccessRule($NewAclRule)
    Set-Acl $FilePath $ACL

    Write-Host "New ACL Added to $FilePath" -ForegroundColor Green
    $ConfirmAcl = Get-Acl -LiteralPath $FilePath
    $ConfirmAcl.Access | Where-Object {$_.IdentityReference -eq $NewIdentity}
}
function Transfer-DirectoryAcl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]$SourceDirectory,
        [Parameter(Mandatory=$true)]
        [String]$TargetDirectory
    )

    $SourceDirectoryAcl = Get-Acl -LiteralPath $SourceDirectory
    Set-Acl -LiteralPath $TargetDirectory -AclObject $SourceDirectoryAcl

    Write-Host "ACLs Successfully Transferred to $TargetDirectory" -ForegroundColor Green
    $ConfirmDirectoryAcl = Get-Acl -LiteralPath $TargetDirectory
    $ConfirmDirectoryAcl | Format-List
}

Write-Host "ACL Management"
Write-Host "1 - Copy ACL from one principal to another on the same directory"
Write-Host "2 - Copy ACLs from one directory to another"
Write-Host "0 - Exit"
$ManagementOption = Read-Host "Select"
switch($ManagementOption)
{
    1{
        Transfer-UserAcl
    }
    2{
        Transfer-DirectoryAcl
    }
    Default{
        exit
    }
}