	function Plagueis {
		$path = '\\twcustomer.local\hosted\twcustomer'
		$share = "TWCustomer"
	
		$shareStats = @()
		#I NEED THE A
	 
		#Make sure the A drive letter is free. It will throw an error if it's already in use. Chill. 
	
		Remove-PSDrive -Name A | out-null
	
	
		for ($i=1; $i -lt 30; $i++) {
	
	
	
			New-PSDrive -Persist -Name "A" -Root $path$i -PSProvider FileSystem | out-null
	
			$shareStats += '--------------------------'
			Get-DfsrFolder -Name $share$i | Select-Object Name | Format-Table -AutoSize
	
			Get-DfsrReplicatioNGroup -Name $share$i | Get-DfsrConnection | Format-Table -AutoSize
		
			   $disk = Get-WmiObject -Class Win32_logicaldisk -Filter "DeviceID = 'A:'" 
			   
			$shareStats += $share+$i
			$shareStats += $disk | Select-Object -Property @{L='Free Space';E={"{0:N2} GB" -f ($_.FreeSpace /1GB)}},@{L="Total Space";E={"{0:N2} GB" -f ($_.Size/1GB)}} | Format-Table -AutoSize
	
			#Write-Host $var1, $var2, $diskinfo -NoNewline | Format-Table -AutoSize
	
			Remove-PSDrive -Name A
	
		}
		$shareStats += '--------------------------'
		$shareStats | Out-File -FilePath "C:\Automation\Audit\TWCustomer Shares Space Audit.txt"
		Invoke-Item -Path "C:\Automation\Audit\TWCustomer Shares Space Audit.txt"
	}
	