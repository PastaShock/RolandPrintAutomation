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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
	$dirs = Get-ChildItem $tdc -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
	$dirs | Foreach-Object { Remove-Item $_ }
}

# Function pushScripts {
# 	#	Chrome dev console script
# 	Copy-Item "$scriptsHome\NS_JS.js"		"$shareDrive`scripts"

# 	#	print labels from a text file in batches
# 	Copy-Item "$scriptsHome\batchlabelfromlist.ps1" "$shareDrive`scripts"

# 	#	takes list of orders and sends them to the Versaworks queue
# 	#	and prints req'd files; alised to Yolo
# 	Copy-Item "$scriptsHome\batchprint.ps1"	"$shareDrive`scripts"

# 	#	common functions shared between scripts
# 	Copy-Item "$scriptsHome\lib.ps1"		"$shareDrive`scripts"

# 	#	collect information from orders.json and prep the info
# 	#	for queueing/printing
# 	Copy-Item "$scriptsHome\OrderList.ps1"		"$shareDrive`scripts"

# 	#	script for printing a normal incentive/OTK order
# 	Copy-Item "$scriptsHome\print.ps1"		"$shareDrive`scripts"

# 	#	setup for the filsystem in the sharedrive, set working dir
# 	Copy-Item "$scriptsHome\today.ps1"		"$shareDrive`scripts"

# 	#	script for looking up past orders
# 	Copy-Item "$scriptsHome\turboReprint.ps1"	"$shareDrive`scripts"

# 	#	powershell user profile script
# 	Copy-Item $profile "$shareDrive`scripts\profile.ps1"
# }
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
function DATABASEREINIT {
	return $ORDERS = Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT ; #cat $DATABASE | CONVERTFROM-JSON
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
			}
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
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

Function NIX_CHNG {wsl cd}

Function NIX_GREP {wsl grep}

Function NIX_LIST {wsl ls}

Function ll {
	get-childitem | sort-object -property LastWriteTime | Select-Object mode,lastWriteTime,name
}
Function lsd {get-childitem -Directory | sort-object -property Name | Select-Object lastwritetime, name}

Function HowMany { (get-childitem -include "Order - *.pdf" -r).length}

Function check { 
	$a = Get-ChildItem -include "PICKINGTICKET*.pdf" -r;
	$b = Get-ChildItem -include "SalesOrd_*.pdf" -r;
	$a = $a | ForEach-Object{$_.name.trimstart('PICKINGTICKET').trimend('.pdf')}
	$b = $b | ForEach-Object{$_.name.trimstart('SalesOrd_').trimend('.pdf')}
	write-host "input: INT`toutput: EXT`tCount: "$a.count
	$baseUrl = "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label="
	if ($null -ne $a) {
		compare-object -referenceObject $a -differenceObject $b -passthru | ForEach-Object{
			if ($_.SideIndicator -eq '=>') {
				chrome "$baseUrl`Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$_"
				Write-Output "pickingTicket: $_"
			} else {
				chrome "$baseUrl`Packing+Slip&formnumber=129&trantype=salesord&id=$_"
				Write-Output "salesOrder: $_"
			}
			Start-Sleep 1;
		}
	}
}

Function getDate {
	$date = get-date -Format "dd-MM-yy"
	return "$PrintLogs\$Date.txt"
}

Function cleanUp {
	$tdc=Get-Location
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
new-alias -name hashtwm "C:\users\$user`\downloads\HashTWM-master\hashtwm.exe"
$DATABASE = $shareDrive+"temp\ORDERS_DATABASE.JSON"
$printlogs = $shareDrive+"temp\$user`_printLogs"
$printlist = $shareDrive+"temp\$user`_printlist.txt"
$labels = $shareDrive+"temp\labels.txt"
$log = getDate
new-alias -name twm "C:\users\rolanda\downloads\HashTWM-master\hashtwm.exe"
try { $null = Get-Command concfg -ea stop; concfg tokencolor -n disable } catch { }
# $ORDERS = ""
function global:DATABASEREINIT {
	Get-Content $DATABASE | CONVERTFROM-JSON
}
$ORDERS = DATABASEREINIT;
