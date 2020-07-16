$ServerName = Read-Host "ENTER SQL SERVER AND INSTANCE (i.e. HVSQL4\SQLEXPRESS6)"
$DatabaseName = Read-Host "ENTER DATABASE NAME"
$QueryUpdate = "UPDATE dbo.GlobalDefaults SET dbo.GlobalDefaults.StorageLocationUNC = Null"
$QuerySelect = "Select dbo.GlobalDefaults.StorageLocationUNC from dbo.GlobalDefaults"

#Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30

#connect and execute update
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($QueryUpdate,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)
$conn.Close()

#connect and execute select to verify StorageLocationUNC shows nothing
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};Integrated Security=True;Connect Timeout={2}" -f $ServerName,$DatabaseName,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$cmd=New-Object system.Data.SqlClient.SqlCommand($QuerySelect,$conn)
$cmd.CommandTimeout=$QueryTimeout
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
[void]$da.fill($ds)
$conn.Close()
$ds.Tables
