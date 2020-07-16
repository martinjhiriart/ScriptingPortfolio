function Transfer-Item {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$FilePathOfItem,
        [Parameter(Mandatory = $true)]
        [String]$DestinationFilePath,
        [Parameter(Mandatory = $true)]
        [String]$EmailAddress
    )
    Move-Item -Path $FilePathOfItem -Destination $DestinationFilePath

    $FromAddress = "powershell@trialworks.com"
    $SMTPServer = "smtp-relay.gmail.com"
    $SMTPPort = "587"

    Send-MailMessage -To $EmailAddress -From $FromAddress -Subject "File Was Successfully Moved" -BodyAsHtml "The move from $FilePathOfItem to $DestinationFilePath has completed successfully" -SmtpServer $SMTPServer -Port $SMTPPort
}

Transfer-Item