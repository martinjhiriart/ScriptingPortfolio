$Path = Read-Host "Enter File Path to Check ACLs"
$CheckAcl = Get-Acl -Path $Path; $CheckAcl.Access | Select-Object IdentityReference,FileSystemRights