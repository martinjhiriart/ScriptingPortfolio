$FilePaths = @()
$FilePaths += Get-ChildItem -Path K:\Cardinal -Recurse | Where-Object {$_.LastWriteTime -gt '6/24/20'} | Select-Object FullName
$FilePaths | Export-Excel -AutoSize -TableName CardinalFilesToRestore -WorksheetName "Files 6/24" -Path "C:\Automation\DevTools\Scripts\Hosting DevOps Repo\Output\Results\CardinalFileRestore_6-24-20.xlsx" -Show
