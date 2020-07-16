#check if we have permission to access hyper-v
$allVMs = get-vm -ErrorAction SilentlyContinue
if(-not $?){
	Write-Error "Can't access Hyper-V system - make sure you have access to it (you can try running Get-VM in a powershell window)"
	exit
} else {
	"Able to access Hyper-V system - there are $($allVMs.Count) VMs on this system"
}
$DefaultSIL = '\\192.168.99.154\ISOs\TW2016r2StdFixedSysPrep1.vhdx'
if($global:SyspreppedImageLocation){
	$DefaultSIL = $global:SyspreppedImageLocation
}
$global:SyspreppedImageLocation = if($Value=(Read-Host "Sysprepped image location (enter for default:) [$DefaultSIL]")){$Value}else{$DefaultSIL}
if(!(Test-Path $global:SyspreppedImageLocation)){
	Write-Error "Can't access file $global:SyspreppedImageLocation - exiting"
	exit
}
$DefaultDDF = 'D:\Hyper-V\VDisks'
if($global:DriveDestinationFolder){
	$DefaultDDF = $global:DriveDestinationFolder
}
$global:DriveDestinationFolder = if($Value=(Read-Host "Virtual disk destination folder (enter for default:) [$DefaultDDF]")){$Value}else{$DefaultDDF}
if ($global:DriveDestinationFolder -notmatch '.+?\\$')
{
	$global:DriveDestinationFolder += '\'
}
if(!(Test-Path $global:DriveDestinationFolder)){
	Write-Error "Can't access file $global:DriveDestinationFolder - exiting"
	exit
}
$DefaultVMDest = 'D:\Hyper-V\VMs\'
if($global:VMDestinationFolder){
	$DefaultVMDest = $global:VMDestinationFolder
}
$global:VMDestinationFolder = if($Value=(Read-Host "VM config file destination folder (enter for default:) [$DefaultVMDest]")){$Value}else{$DefaultVMDest}
if ($global:VMDestinationFolder -notmatch '.+?\\$')
{
	$global:VMDestinationFolder += '\'
}
if(!(Test-Path $global:VMDestinationFolder)){
	Write-Error "Can't access file $global:VMDestinationFolder - exiting"
	exit
}
"Using source image file $global:SyspreppedImageLocation"
"Using destination vhdx directory $global:DriveDestinationFolder"
"Using destination vm config directory $global:VMDestinationFolder"
"All files and folders present - proceeding"

$numCores = 4
$numMemory = 15360MB

Function Create-VM
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$VMName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("TWCustomer.local","NeedlesHosted.local")]$VMDomain
    )

    if($VMDomain -eq "TWCustomer.local")
    {
        $vlanID = 10
    }
    if($VMDomain -eq "NeedlesHosted.local")
    {
        $vlanID = 100
    }

    $HVName = $VMName
    $host.ui.RawUI.WindowTitle = $HVName

    "Copying VHDX..."
    $DestinationFile = $DriveDestinationFolder + $VMName + ".vhdx"
    Copy-Item -Path $SyspreppedImageLocation -Destination $DestinationFile

    "Finished copying. Creating VM"

    $vm = New-VM -Name $HVName `
        -Path $VMDestinationFolder `
        -Generation 2 `
        -MemoryStartupBytes $numMemory `
        -VHDPath $DestinationFile
    if(!$vm){
        Write-Error "Could not create VM $vm - see above error"
        exit
    }

    "Configuring VM settings..."
    Set-VMProcessor -VMName $vm.VMName -Count $numCores
    Set-VMMemory -VMName $vm.VMName -DynamicMemoryEnabled $false
    $switch = Get-VMSwitch | Get-Random
    $switch | Connect-VMNetworkAdapter -VMName $vm.VMName
    Set-VMNetworkAdapterVlan -VMName $vm.VMName -Access -VlanId $vlanID

    "Starting VM"
    Start-VM $vm
    "Done"
}
$name = Read-Host -Prompt "Enter VM Name"
$domain = Read-Host -Prompt "Enter the Domain for the VM"

Create-VM -VMName $name -VMDomain $domain