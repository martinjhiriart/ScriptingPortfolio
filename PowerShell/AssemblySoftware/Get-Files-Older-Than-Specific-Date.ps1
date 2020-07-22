$FilePaths = @()
$FilePaths += Get-ChildItem -Path "<PATH TO GET FILES FROM>" -Recurse | Where-Object {$_.LastWriteTime -gt '<DATE TO COMPARE>'} | Select-Object FullName
$FilePaths | Export-Excel -AutoSize -TableName <EXCEL TABLE NAME> -WorksheetName "<Name of Excel Tab>" -Path "<FILE PATH TO OUTPUT EXCEL SPREADSHEET>" -Show
