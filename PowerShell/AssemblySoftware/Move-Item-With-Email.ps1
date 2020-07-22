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

    $FromAddress = "<FROM ADDRESS>"
    $SMTPServer = "<SMTP SERVER INFO>"
    $SMTPPort = "<SMTP PORT>"

    Send-MailMessage -To $EmailAddress -From $FromAddress -Subject "File Was Successfully Moved" -BodyAsHtml "The move from $FilePathOfItem to $DestinationFilePath has completed successfully" -SmtpServer $SMTPServer -Port $SMTPPort
}

Transfer-Item