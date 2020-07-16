$RemoteServer = Read-Host "Enter Remote Server Name"
Invoke-Command -ComputerName $RemoteServer {
    $AssemblyPath = "C:\Program Files (x86)\Assembly Software LLC\TrialWorks XML Importer"
    $TrialWorksPath = "C:\Program Files (x86)\TrialWorks LLC\TrialWorks XML Importer"
    $LawexCorpPath = "C:\Program Files (x86)\Lawex Corporation\TrialWorks XML Importer"
    $PathTest = Test-Path -Path $AssemblyPath
    if($PathTest -eq $true)
    {
        Write-Host "TrialWorks XML Importer Path is " -NoNewline
        Write-Host $AssemblyPath -ForegroundColor Green
    }
    elseif($PathTest -eq $false)
    {
        $NextPathTest = Test-Path -Path $TrialWorksPath
        if($NextPathTest -eq $true)
        {
            Write-Host "TrialWorks XML Importer Path is " -NoNewline 
            Write-Host $TrialWorksPath -ForegroundColor Green
        }
        elseif ($NextPathTest -eq $false) 
        {
            $LastPathTest = Test-Path -Path $LawexCorpPath
            if($LastPathTest -eq $true)
            {
                Write-Host "TrialWorks XML Importer Path is " -NoNewline
                Write-Host $LawexCorpPath -ForegroundColor Green
            }
            else{
                Write-Warning -Message "TrialWorks XML Importer Directory Not Found"
            }
        }
    }
    
}