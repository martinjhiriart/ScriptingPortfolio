$OldIdentities =@() 
$OldIdentities += Import-Csv -Path "<PATH WHERE CSV IS STORED>"
$SIDMappingArray = @()
$UserMappingArray =@()
foreach($Identity in $OldIdentities)
{
    $SIDMappingArray += [PSCustomObject]@{
        OriginalSID = $Identity.SID
        NewIdentity = "<NEW DOMAIN>\" + $Identity.SamAccountName
    }
    $UserMappingArray += [PSCustomObject]@{
        OriginalUserName = "<OLD DOMAIN>\" + $Identity.SamAccountName
        NewUserName = "<NEW DOMAIN>\" + $Identity.SamAccountName
    }
}
$SIDMappingArray | Export-Csv -Path "<FILE PATH FOR NEW CSV>\SIDMappingFile.csv" -NoTypeInformation
$UserMappingArray | Export-Csv -Path "<FILE PATH FOR NEW CSV>\UserMappingFile.csv" -NoTypeInformation  