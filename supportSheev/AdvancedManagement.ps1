Set-Location -LiteralPath 'C:\Program Files\WindowsPowerShell\Modules\Maul'
$port = $args[0]
$pcName = $args[1]
do {
Write-Host ''
Write-Host '===============================================' -ForegroundColor Magenta
Write-Host 'Advanced Management Console for' , $pcName -ForegroundColor Cyan
Write-Host '===============================================' -ForegroundColor Magenta
Write-Host '1 - RDP Connect'
Write-Host '0 - Exit' -ForegroundColor Red
Write-Host 'Make a Selection: ' -NoNewline -ForegroundColor Yellow
$advMgmt = Read-Host

switch($advMgmt)
{

    1{
        mstsc /v:$pc`:$port
        Clear-Host
    }
    0{
        Clear-Host
    }
  }
Clear-Host
}while ($advMgmt -ne 0)