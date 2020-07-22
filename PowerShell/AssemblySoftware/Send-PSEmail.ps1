function Email{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$ToAddress,
        [Parameter(Mandatory)]
        [String]$Subject,
        [Parameter(Mandatory)]
        [String]$Message,
        [Parameter(Mandatory)]
        [ValidateSet("Yes","No")]$AddAttachment
    )
    $FromAddress = "<FROM ADDRESS>"
    $SMTP_Server = "<SMTP SERVER>"
    $SMTP_Port = "<SMTP PORT>"
    if($AddAttachment -eq "Yes")
    {
        $AttachmentPath = Read-Host "Enter Path to File to Attach"
        Send-MailMessage -SmtpServer $SMTP_Server -Port $SMTP_Port -From $FromAddress -To $ToAddress -Subject $Subject -BodyAsHtml $Message -Attachments $AttachmentPath
    }
    else 
    {
        Send-MailMessage -SmtpServer $SMTP_Server -Port $SMTP_Port -From $FromAddress -To $ToAddress -Subject $Subject -BodyAsHtml -$Message
    }
    
}