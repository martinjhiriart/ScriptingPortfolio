$pc = $args[0]
$domainCreds = $args[1]
do{
    Write-Host '==============================' -ForegroundColor Magenta
    Write-Host 'Run Command on', $pc -ForegroundColor Cyan
    Write-Host '==============================' -ForegroundColor Magenta
    Write-Host 'Enter Remote Command: ' -NoNewline  -ForegroundColor Yellow
    $command = Read-Host
    $scriptBlock = [ScriptBlock]::Create($command)

    $remoteCommand = Invoke-Command -HideComputerName $pc -Credential $domainCreds -ScriptBlock $scriptBlock
    Write-Output $remoteCommand
    Write-Host ' '
    Write-Host 'Enter Another Command?' -NoNewline -ForegroundColor Yellow
    Write-Host '(Y/N): ' -NoNewline
    $anotherCommand = Read-Host
    switch ($anotherCommand)
    {
        'Y'{
            Clear-Host
        }
    }
} while ($anotherCommand -ne 'N')


