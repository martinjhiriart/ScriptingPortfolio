$ClawsonOldIdentities =@() 
$ClawsonOldIdentities += Import-Csv -Path C:\Users\mhiriart\Desktop\ClawsonActiveUsers.csv
$SIDMappingArray = @()
$UserMappingArray =@()
foreach($Identity in $ClawsonOldIdentities)
{
    $SIDMappingArray += [PSCustomObject]@{
        OriginalSID = $Identity.SID
        NewIdentity = "hosting.trialworks.local\" + $Identity.SamAccountName
    }
    $UserMappingArray += [PSCustomObject]@{
        OriginalUserName = "CS.local\" + $Identity.SamAccountName
        NewUserName = "hosting.trialworks.local\" + $Identity.SamAccountName
    }
}
$SIDMappingArray | Export-Csv -Path "C:\Users\mhiriart\Desktop\ClawsonSIDMappingFile.csv" -NoTypeInformation
$UserMappingArray | Export-Csv -Path "C:\Users\mhiriart\Desktop\ClawsonUserMappingFile.csv" -NoTypeInformation