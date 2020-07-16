Write-Host "What Kind of RoboCopy Do You Need?"
Write-Host "1 - Data Transfer To/From Hosted Environment"
Write-Host "2 - Differential Copy"
Write-Host "0 - Exit"
$robocopyType = Read-Host "Select"

switch($robocopyType)
{
    1{
        $dynFlags = @("/e", "/z")
        
    }
    2{
        $days = Read-Host "Enter the Number of Days For Differential Copy"
        $maxLad = "/maxlad:" + $days
        $maxAge = "/maxage:" + $days
        $dynFlags = @("/e", "/z", "$maxLad", "$maxAge")
    }
}

#########################################
#   User Input for RoboCopy Arguments   #
#########################################
    while(($null -eq $remotePC) -or ($remotePC -eq ''))
    {
        $remotePC = Read-Host "What Computer do you want to run this from?"
    }
    while(($null -eq $customerName) -or ($customerName -eq ''))
    {
        $customerName = Read-Host "What Firm is this RoboCopy For?"
    }
    while(($null -eq $sourceAddr) -or ($sourceAddr -eq ''))
    {
        $sourceAddr = Read-Host 'Please Enter Source Address'
    }
    while(($null -eq $destAddr) -or ($destAddr -eq ''))
    {
        $destAddr = Read-Host 'Please Enter Destination Address'
    }
    $logName = $customerName + " " + "$(Get-Date -f MM-dd-yyyy)" + ".log"
    while(($null -eq $threadCount) -or ($threadCount -eq ''))
    {
        $threadCount = Read-Host 'Enter Number of Threads to Run With'
    }
    $threads = "/mt:" + $threadCount
    $logFile = $remotePC +"\C$\RoboCopyLogs\" + $logName
    $log = "/log:" + $logFile
    $fixedFlags = @("$threads", "$log")
    $cmdArgs = @("$sourceAddr", "$destAddr", $dynFlags, $fixedFlags)

#############################
#   SMTP Relay Information  #
#############################
$From = 'robocopy@trialworks.com'
while(($null -eq $To) -or ($To -eq ''))
{
    $To = Read-Host "Who do I notify when the transfer is complete? (Enter Email Address)"
}
$Subject = $customerName + ' Transfer Completed at ' + $(Get-Date)
$Body = 'Attached below is the log for the RoboCopy transfer of ' + $customerName + "'s data"
$Attachment = $logFile
$SMTPServer = 'smtp-relay.gmail.com'
$SMTPPort = '587'

Invoke-Command -HideComputerName $remotePC {robocopy @cmdArgs} 
Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -Attachments $Attachment 