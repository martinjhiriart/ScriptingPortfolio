#This formats the name of the report so that we can know when the report was run
$ExcelReportPath = "<FILE PATH FOR FINAL REPORT>\DriveMappingGPOResults-" + "$(Get-Date -f MM-dd-yyyy)"+".xlsx" 
#Queries the OU where our customer sub-OUs exist, and isolates all of the GPOs linked to those OUs
$LinkedGPOs  = Get-ADOrganizationalUnit -Filter "*" -SearchBase '<DISTINGUISHED NAME OF OU THAT DRIVE MAPPING GPOs APPLY TO>' -SearchScope OneLevel | Select-Object -ExpandProperty LinkedGroupPolicyObjects
#Filters out everything except the GUID for the linked GPOs
$LinkedGPOGUIDs = $LinkedGPOs | ForEach-object{$_.Substring(4,36)}
#An array to hold the results of what these GPO GUIDs correspond to
$GPOLists =@()
#Goes through each GUID and checks to make sure we are only getting "Drive Mapping" GPOs added
$LinkedGPOGUIDs | ForEach-object {
    $GPOLists += Get-GPO -Guid $_ | Where-Object{$_.DisplayName -like "*Drive*Mapping*"} |Select-Object DomainName,Id,DisplayName
}
#This is an array to hold the information about each Drive Mapping GPO
$GPOMappings =@()
#This is an array to hold the filtered information to only show Y: drive mappngs, since our customers have multiple drive letter mappings
$GPOYDriveOnly = @()
#Goes through each entry in the GPOLists array and pulls the corresponding information of what drive letter, the path it is mapping, etc. and adds it to the GPOMappings array
foreach($GPO in $GPOLists)
{
    $GPOID = $GPO.Id
    $GPODom = $GPO.DomainName
    $GPODisp = $GPO.DisplayName
    [xml]$DriveXML = Get-Content "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences\Drives\Drives.xml"
    foreach ( $drivemap in $DriveXML.Drives.Drive )
    {
        $GPOMappings += New-Object PSObject -Property @{
            GPOName = $GPODisp
            DriveLetter = $drivemap.Properties.Letter + ":"
            DrivePath = $drivemap.Properties.Path
            DriveAction = $drivemap.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
            DriveLabel = $drivemap.Properties.label
            DrivePersistent = $drivemap.Properties.persistent.Replace("0","False").Replace("1","True")
        }
    }
}
#Goes through and filters for only Y: drive GPOs and also filters out any Delete Action Drive Mappings, then adds the results to the GPOYDriveOnly array.
foreach($GPOMapping in $GPOMappings)
{
    $GPOYDriveOnly += $GPOMapping | Where-Object {($_.DriveLetter -eq "Y:") -and ($_.DriveAction -ne "Delete")}
}
#Outputs the contents of the array to an Excel file with the information stored in a table at the path listed at the beginning of this file.
$GPOYDriveOnly | Export-Excel -AutoSize -TableName YDriveMappingGPOs -WorksheetName "Customer Drive Mapping GPOs" -Path $ExcelReportPath