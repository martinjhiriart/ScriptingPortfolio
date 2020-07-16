#$PremiumServersOuPath ='OU=Premium Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
#$PremiumServers = Get-ADComputer -SearchBase $PremiumServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$RDPServersOuPath ='OU=RDP Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$RDPServers = Get-ADComputer -SearchBase $RDPServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$HawaiiServersOUPath = 'OU=Hawaii Servers,OU=Corporate Servers,DC=TWCustomer,DC=local'
$HawaiiServers = Get-ADComputer -SearchBase $HawaiiServersOuPath -Filter * | Select-Object -ExpandProperty Name | Sort-Object
$AllServers = $HawaiiServers + $RDPServers | Sort-Object
foreach($Computer in $RDPServers){
    $Group = "Remote Desktop Users"
    $GetGroupUser = Get-CimInstance -Class Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$Computer',Name='$Group'""" -ComputerName $Computer
    $GetGroupUserPartComponent = $GetGroupUser.PartComponent 
    Write-Host "================="  
    $Computer
    Write-Host "=================" 
    #Write-Host "Group:  $Group" 
    Write-Host "Members:" 
 
    # Iterate through the group membership, and return the members.  
    If ($GetGroupUserPartComponent -eq $Null) 
    { 
      Write-Host "There are no members." 
    } 
      Else 
    { 
      Foreach ($Member in $GetGroupUserPartComponent) 
      { 
        $MemberDomain = $Member.Domain 
        $MemberName = $Member.Name 
        Write-Host "$MemberDomain\$MemberName" 
      } 
    }
    Write-Host "-----------------"
    Write-Host ""
}