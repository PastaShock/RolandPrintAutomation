$scriptsHome = "C:\ps"
# $shareDrive = "Z:\"
$shareDrive = "R:\"
# $shareDrive = "\\DESKTOP-J62DQLS\RaiseDrive\"
# $shareDrive = "F:\"
$user = $env:UserName
$user_id = "2800e06c-6617-4534-b9bd-56497576aa7b"
$db_uri = "http://database:3000/"

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
				Write-Output "`tmissed pickingTicket: $_"
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
				Write-Output "`tmissed salesOrder: $_"
			}
			Start-Sleep 2.5;
		}
	}
}

Function check {
	if (Test-Path -Path orders.json) {
		$checking = Get-Content orders.json | ConvertFrom-Json;
		$checking = @($checking.psobject.properties | ForEach-Object { $_.Name });
		write-host "Checking" $checking.count "for" $(Get-ChildItem -i 'sales*.pdf' -r).count "sales/" $(Get-ChildItem -i 'PICK*.pdf' -r).count "pick";
		$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
		for ($i = 0; $i -lt $checking.count; $i++) {
			# Write-Host "`tChecking orderId" $checking[$i] "..."
			$path = "PICKINGTICKET" + $checking[$i] + ".pdf"
			$pick = Test-Path -Path $path
			if (!$pick) {
				$url = $baseUrl + "Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=" + $checking[$i]
				chrome $url
				Write-Host "`tmissing pickingTicket: "$checking[$i]
				$errMsg = $checking[$i] + ", missing picking slip"
				masterErrorLog $errMsg
				Start-Sleep 2.5;
			}
			$path = "SalesOrd_" + $checking[$i] + ".pdf"
			$pack = Test-Path -Path $path
			if (!$pack) {
				$url = $baseUrl + "Packing+Slip&formnumber=129&trantype=salesord&id=" + $checking[$i]
				chrome $url
				Write-Host "`tmissing salesOrder: "$checking[$i]
				$errMsg = $checking[$i] + ", missing sales order form"
				masterErrorLog $errMsg
				Start-Sleep 2.5;
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
	# clear and write the contents of the $profile into a text file
	clear-content $scriptsHome/profile.ps1
	Copy-Item $profile $scriptsHome/profile.ps1
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

Function sss {
	$ssList = (Get-ChildItem -path C:\users\Rolanda\Pictures\Screenshots);
	$ssList = $ssList | sort-object -property LastWriteTime -descending | select -f 1;
	Copy-Item $ssList.fullname D:\OneDrive\Pictures\Screenshots;
}

Function masterErrorLog($data) {
	$date = get-date;
	# set log location
	$logName = "logs\error-log"
		# check if sharedrive exists, check if file exists
		if (test-path $shareDrive+$logName) {
			$loglocation = $shareDrive+$logName
		}
		$loglocation = $shareDrive+$logName
		# check if local backup log exists

	# append extra data to log, ie. date, username
	$logData = "$date, $user, $data"
	# write to log
	add-content -Path $loglocation $logData
}

function Test-FileLock {
   param (
     [parameter(Mandatory=$true)][string]$Path
   )
   $oFile = New-Object System.IO.FileInfo $Path
   if ((Test-Path -Path $Path) -eq $false) {
	# file doesn't exist
	# make master log record of requested file's unavailability
	# add-masterlogrecord $severity $script $filename
	# Add-MasterLogRecord "High" "Test-FileLock" $Path
     return $false
   }
   try {
     $oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
     if ($oStream) {
       $oStream.Close()
     }
	 # File is not locked by a process.
     return $false
   } catch {
     # file is locked by a process.
     return $true
   }
}

function dbAvailability() {
   while ($database) {if ((Test-FileLock $DATABASE) -ne $fileStatus) {
           $fileStatus = Test-FileLock $DATABASE;
           $time = Get-Date;
           write-host "$time, watcher, , DBAvailability: $fileStatus";
        }
    }
}

function orderForm() {
	param (
		# Should be the date passed as a string:
		[Parameter(Mandatory=$true)]
		[string]
		$orderId,
		# form type pick, pack
		[Parameter(Mandatory=$true)]
		[String]
		$type
	)
	$baseUrl;
	$url;
	switch ($type) {
		"pick" {
			$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
			$url = $baseUrl + "Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=" + $orderId
		 }
		"pack" {
			$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&formnumber=129&trantype=salesord&id="
			$url = $baseUrl + $orderId
		 }
		Default {}
	}
		chrome $url
}

function convDate() {
	param (
		# Should be the date passed as a string:
		[Parameter(Mandatory=$true)]
		[string]
		$dateString
	)
	$TZ = [TimeZoneInfo]::local.id; $date = [datetime](get-date($dateString)); $fixeddate = $date.toString("ddd MM dd yyyy HH:mm:ss");$GMTOffset = "GMT$($date.toString("zzzz"))"; write-output "$fixeddate $GMTOffset ($TZ)"
}

function replaceLogos() {
	param (
		# pass the fund ID / file name
		[parameter(Mandatory=$true)]
		[string]
		$fundID
	)
	$fileLocations = gci -path $shareDrive\AA* -include "$fundId*" -r;
	$fileLocations | %{
		write-host "replacing $_ with updated $($_.name)";
		copy-item $_.name $_;
	}
	$uniqueArray = @();
	$fileLocations | %{
		$uniqueArray += $_.name
	};
	$uniqueArray = $uniqueArray | Select-Object -Unique;
	$uniqueArray
	$uniqueArray | %{
		remove-item $_
	};
};;


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
new-alias -name csvTool $scriptsHome\csvTool.ps1 
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

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
