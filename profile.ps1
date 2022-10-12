$scriptsHome = "C:\ps"
$shareDrive = "F:\"
$user = $env:UserName

function Prompt {

	$curtime = Get-Date -f HH:mm:ss

	#Write-Host -NoNewLine "$" 
	Write-Host -NoNewLine "[$curtime]" -foregroundcolor cyan
	#$SPLITDIRECTORY = split-path -leaf -path (Get-Location)
	Write-Host -NoNewLine ( Get-Location | Get-Item ).Name
	Write-Host -NoNewLine ">"

	$host.UI.RawUI.WindowTitle = "PS >> User: $curUser >> $((Get-Location).Path)"

	Return " "

}

Function NIX_CHNG { wsl cd }

Function NIX_GREP { wsl grep }

Function NIX_LIST { wsl ls }

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode, lastWriteTime, name
}
Function lsd { get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name }

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length }

Function czech { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object { $_.name.trimstart('PICKINGTICKET').trimend('.pdf') }
	$b = $b | ForEach-Object { $_.name.trimstart('SalesOrd_').trimend('.pdf') }
	write-host "input: INT`toutput: EXT`tCount: "$a.count"/"$b.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object {
			if ($_.SideIndicator -eq '=>') {
				# Invoke-WebRequest -uri "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			}
			elseif ($_.SideIndicator -eq '<=') {
				$url = $baseUrl + "Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				# $user = 'georgep@snap-raise.com'
				# $pass = 'vugQjgvRYMg9Yex'
				# $pair = "$($user):$($pass)"
				# $encCred = [system.convert]::ToBase64String([system.text.encoding]::ASCII.getBytes($pair))
				# $basicAuth = "Basic $encCred"
				# $headers = @{
				# 	Authorization = $basicAuth
				# }
				# $res = Invoke-WebRequest -Uri $url -Headers $headers
				# $res.content
				chrome $url
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function check {
	if (Test-Path -Path orders.json) {
		$checking = Get-Content orders.json | ConvertFrom-Json;
		$checking = $checking.psobject.properties | ForEach-Object { $_.Name };
		# write-host "Checking" $checking.count "orders from orders.json";
		$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
		for ($i = 0; $i -lt $checking.count; $i++) {
			# Write-Host "`tChecking orderId" $checking[$i] "..."
			$path = "PICKINGTICKET" + $checking[$i] + ".pdf"
			$pick = Test-Path -Path $path
			if (!$pick) {
				$url = $baseUrl + "Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=" + $checking[$i]
				chrome $url
				# Write-Host "`tpickingTicket: "$checking[$i]
				Start-Sleep 2;
			}
			$path = "SalesOrd_" + $checking[$i] + ".pdf"
			$pack = Test-Path -Path $path
			if (!$pack) {
				$url = $baseUrl + "Packing+Slip&formnumber=129&trantype=salesord&id=" + $checking[$i]
				$url
				chrome $url
				# Write-Host "`tsalesOrder: "$checking[$i]
				Start-Sleep 2;
			}
		}
	}
	else {
		Write-Output 'orders.json was not found, aborting'
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc = Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

Function pushScripts {
	# write the contents of the $profile into a text file
	Get-Content $profile >> $scriptsHome/profile.ps1
	# Take the list of files from the files.txt list
	Get-Content $shareDrive/scripts/files.txt | ForEach-Object {
		Copy-Item $scriptsHome/$_ $shareDrive/scripts/$_ -Force 
		Write-Output "copying: $_";
	}
}

Function pullScripts {
	# Take the list of files from the files.txt list
	Get-Content $shareDrive/scripts/files.txt | ForEach-Object {
		Copy-Item $shareDrive/scripts/$_ $scriptsHome/$_ 
		# Write-Output $_;
	}
	notepad $profile
	notepad "$shareDrive`scripts\profile.ps1"
}

remove-item alias:ls
#remove-item alias:cd
#set-alias -name cd -value NIX_CHNG
set-alias -name ls -value NIX_LIST
new-alias -name grep -value NIX_GREP
new-alias -name search $scriptsHome\reprintfinder.ps1
new-alias -name rep $scriptsHome\turboReprint.ps1
new-alias -name yolo $scriptsHome\batchPrint.ps1
new-alias -name printLabels $scriptsHome\batchlabelfromlist.ps1
new-alias -name excel "C:\Program Files (x86)\Microsoft Office\root\Office16\Excel.exe" -option ReadOnly
new-alias -name unhash $scriptsHome\unhash.ps1
new-alias -name chrome	"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
new-alias -name acrobat	"C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"
new-alias -name incentive "$scriptsHome\print.ps1"
new-alias -name yeet $scriptsHome\OrderList.ps1
new-alias -name today $scriptsHome\today.ps1
new-alias -name zebra $scriptsHome\zebraprint.ps1
new-alias -name oneDrive $scriptsHome\checkSharePoint.ps1
new-alias -name reprint $scriptsHome\batchReprint.ps1
$DATABASE = $shareDrive + "temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive + "temp\$user`_printLogs"
$printlist = $shareDrive + "temp\$user`_printlist.txt"
$labels = $shareDrive + "temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
