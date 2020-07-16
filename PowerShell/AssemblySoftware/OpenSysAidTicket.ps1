$TicketID = Read-Host "Enter SysAid Ticket Number"
$URL = "https://assembly.sysaidit.com/SREdit.jsp?id=" + $TicketID + "&fromId=List&isFromAll=true"

Start-Process -FilePath $URL