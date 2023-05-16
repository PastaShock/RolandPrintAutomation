# print an order based on ID entry
# 2020 George Pastushok
#
# FOR NETSUITE; VERSION 1.2

[cmdletbinding()]
Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("orderID", "i")]
    # [ValidatePattern("^\d{6}$")]
    [String[]] $ID,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("printer", "p")]
    [ValidateRange(1, 4)]
    [int] $desiredPrinter,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("queue", "q")]
    [ValidateRange(1, 5)]
    [int] $desiredQueue,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("type", "t")]
    [switch] $orderType
)
if (!(test-path $printLogs)) {
    mkdir $printLogs
}
$logDate = get-date -Format "dd-MM-yy"
$logName = "$logdate.txt"
if ($null -eq (get-childitem -path $printLogs -include $logname -r)) {
    new-item -name $logname -path $printLogs
}
$logFullName = "$printLogs\$logName"
$divider = "---------------"
# create a list of order ids from the json file
$orders = Get-ChildItem -path $PWD -include 'orders.json' -r 
if ($null -eq $orders) { return }
$orders = get-content $orders | convertfrom-json
$list = $orders | Get-Member
$list = ($list | select-object -property 'Name')
# $brother = "\\WAREHOUSE-SHIPP\Brother PT-D600"

Add-Type -AssemblyName PresentationCore, PresentationFramework

class Logos {
    [string]$name
    [int]$value

    Logos(
        [string]$name,
        [int]$value
    ) {
        $this.name = $name
        $this.value = $value
    }
} 
$logoSizesByApplication = @(
    [Logos]::new('eleven', 0 ),
    [Logos]::new('eight', 0 ),
    [Logos]::new('six', 0 ),
    [Logos]::new('five', 0 ),
    [Logos]::new('four', 0 ),
    [Logos]::new('digital', 0 ),
    [Logos]::new('digiSmall', 0 ),
    [Logos]::new('embroidered', 0 ),
    [Logos]::new('sticker', 0 ),
    [Logos]::new('banner', 0 )
)

function PrintIncentiveOrder($orderID, $p, $i, $orderType) {
    $printer = @("Mary-Kate", "Ashley", "Nicole", "Paris", "Rolanda")
    $Q = @("A", "B", "C", "D", "E")
    $queue = "C:\ProgramData\Roland DG VersaWorks\VersaWorks\Printers\" + $printer[$p] + "\Input-" + $Q[$i]
    # prompt user for ID
    # Find INTERNAL PACKING SLIP PDF with ID match in filename
    $intPath = (Get-ChildItem -path ($shareDrive + "AA*") -include "PICKINGTICKET$orderID.pdf" -r) | Select-Object -f 1
    $orderDir = $intPath.directory.FullName + "\*"
    # prompt user to cancel if the order is OTF
    # $bool = Read-Host -Prompt 'is this order OTF?'
    if ($bool) { return }

    # internal PDF picking slip section------------------------------------
    # if the PDF is not found, get it from the warehouse dash in chrome
    if ($null -eq $intPath) {
        # chrome "https://www.snap-raise.com/warehouse/reports/order?order_id=$orderID"
        chrome "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label=Picking+Ticket&printtype=pickingticket&trantype=salesord&print=T&id=$orderID"
        Write-Output "Internal slip was not found. Downloaded Order - $orderID.pdf from Chrome."
        Write-Output "retrying.."
        start-sleep -seconds 2
        $intPath = (Get-ChildItem -path ($shareDrive + "AA*") -include "PICKINGTICKET$orderID.pdf" -r)
    }
    # print the internal picking slip PDF
    $intPath | foreach-object {
        start-process -FilePath $_.FullName -Verb Print -PassThru | ForEach-Object {
            Start-Sleep 1;
        } | Stop-Process
    }

    # data organization section --------------------------------------------
    appendLog $divider
    # $script = $orders.$orderID | Select-Object -ExpandProperty 'logoScript'
    if ( [bool](($orders.$orderID).PSObject.properties.name -match 'logoScript') ) {
        $script = $orders.$orderID | Select-Object -ExpandProperty 'logoScript'
    }
    else {
        $script = $null
    }
    $fund_id = $orders.$orderID | Select-Object -ExpandProperty 'fundId'
    $salesID = $orders.$orderID | Select-Object -ExpandProperty 'salesOrder'
    if ( [bool](($orders.$orderID).PSObject.properties.name -match 'magentoId') ) {
        $magentoId = $orders.$orderID | Select-Object -ExpandProperty 'magentoId'
    }
    else {
        $magentoId = $null
    }
    $placedOn = $orders.$orderID | Select-Object -ExpandProperty 'placedDate'
    # $downloadDate = $orders.$orderID | Select-Object -expandproperty 'downloadDate'
    # $printDate = (Get-Date -Format "ddd MMM dd yyyy HH:mm:ss G\MTK") + " (Pacific Daylight Time)"# $orders.$orderID | Select-Object -expandproperty 'printDate'
    # $logoid = $orders.$orderID | Select-Object -ExpandProperty 'logoId'
    if ( [bool](($orders.$orderID).PSObject.properties.name -match 'logoId') ) {
        $logoId = $orders.$orderID | Select-Object -ExpandProperty 'logoId'
    }
    else {
        $logoId = $null
    }
    # $priColor = $orders.$orderID | Select-Object -ExpandProperty 'priColor'
    if ( [bool](($orders.$orderID).PSObject.properties.name -match 'priColor') ) {
        $priColor = $orders.$orderID | Select-Object -ExpandProperty 'priColor'
    }
    else {
        $priColor = $null
    }
    # $secColor = $orders.$orderID | Select-Object -ExpandProperty 'secColor'
    if ( [bool](($orders.$orderID).PSObject.properties.name -match 'secColor') ) {
        $secColor = $orders.$orderID | Select-Object -ExpandProperty 'secColor'
    }
    else {
        $secColor = $null
    }
    # Logging to console:
    # if ($null -eq $script) { write-host -ForegroundColor Red "no logo script!"; return } else {
    Write-Output $orders.$orderID
    # Write-Output $orderID
    # Write-Output $salesID
    # write-Output "`t$script"
    # Write-Output "`t$fund_id"
    # Write-Output "`t$placedOn"
    # # logging to the log file on the HDD
    appendLog ("  id:`t" + $orderID)
    appendLog "fund:`t$fund_id"
    appendLog "date:`t$placedOn"
    # appendLog "dnld:`t$downloadDate"
    # appendLog "prnt:`t$printDate"
    appendLog "text:`t$script"
    appendLog "type:`t$logoId"
    appendLog "prim:`t$priColor"
    appendLog "secd:`t$secColor"
    # }

    set-content orders.json ($orders | convertto-json)
    
    # Setup for printing a package label:
    $escapedScript = $script -replace "\|", ""
    
    node 'C:\ps\label_temp\app.js' --script=$escapedScript --orderid=$orderID --salesOrder=$salesID --magentoId=$magentoId --fundraiserId=$fund_id
    # note: the print call will be later to make up for time it takes for the pdf to generate.

    # search for the logos in the HDD, in relevant directories and move them to the auto-queue for Versaworks

    #      WARNING: DUPLICATE ORDERS WILL NOT BE FILTERED OUT!

    if ($fund_id) {

        # ----------
        # reconfigure above script to copy specific logo sizes to their respective queues
        $dirShortName = "...\" + $printer[$p] + "\Input-" + $Q[$i];
        $order = $orders.$orderID
        if ($Q[$i] -ne "C") {
            # ----- Digital ------
            if ($order.digital) {
                $logoFileName = $fund_id + "*_d.eps"
                $test = Test-Path ..\$logoFileName;
                if ($test) {
                    $numLogos = $order.digital
                    Write-Output "`tcopying $logoFileName to $dirShortName $numLogos times";
                    for ($j = 0; $j -lt $order.digital; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_d_$index.eps"
                        copy-item -Path ..\$logoFileName -Destination $destination;
                        Start-Sleep -Milliseconds 750
                    }
                }
                else {
                    masterErrorLog "$orderID, Missing Digital"
                }
            }
            # ----- Digital Small ------
            if ($order.digiSmall) {
                $logoFileName = $fund_id + "*_ds.eps"
                $test = Test-Path ..\$logoFileName;
                if ($test) {
                    $numLogos = $order.digiSmall
                    Write-Output "`tcopying $logoFileName to $dirShortName $numLogos times";
                    for ($j = 0; $j -lt $order.digiSmall; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_ds_$index.eps"
                        copy-item -Path ..\$logoFileName -Destination $destination;
                        Start-Sleep -Milliseconds 750
                    }
                }
                else {
                    masterErrorLog "$orderID, Missing Digital Small"
                }
            }
            # ----------
        }
        else {
            $rollDirName = "r" + (Get-Date -format "MMdd") + "0" + ($p + 1)
            Write-Output "roll mode; dest: $rolldirname"
            # ----- For rolls, do not copy logo multiple times, just once -----
            if ($order.digital) {
                $logoFileName = $fund_id + "*_d.eps"
                $test = Test-Path ..\$rollDirName\$logoFileName;
                $test
                if ($test) {
                    $numLogos = $order.digital
                    for ($j = 0; $j -lt $order.digital; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_d_$index.eps"
                        copy-item -Path ..\$rollDirName\$logoFileName -Destination $destination;
                        Start-Sleep -Milliseconds 750
                    }
                    Write-Output "`tcopying $logoFileName to $dirShortName";
                    # $destination = "$queue\$fund_id`_d.eps"
                }
                else {
                    masterErrorLog "$orderID, Missing Digital"
                }
            }
            # ----- Digital Small ------
            if ($order.digiSmall) {
                $logoFileName = $fund_id + "*_ds.eps"
                $test = Test-Path ..\$rollDirName\$logoFileName;
                if ($test) {
                    $numLogos = $order.digiSmall
                    for ($j = 0; $j -lt $order.digiSmall; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_ds_$index.eps"
                        copy-item -Path ..\$rollDirName\$logoFileName -Destination $destination;
                        Start-Sleep -Milliseconds 750
                    }
                    Write-Output "`tcopying $logoFileName to $dirShortName";
                    # $destination = "$queue\$fund_id`_ds.eps"
                }
                else {
                    masterErrorLog "$orderID, Missing Digital Small"
                }
            }
            # ----- Old Method saved for reference -----
            # $searchResult = Get-ChildItem -path $orderdir -include "$fund_id*.eps" -Recurse
            # $searchResult | ForEach-Object {
            #     $filename = $_.Name
            #     $dirShortName = "...\" + $printer[$p] + "\Input-" + $Q[$i]
            #     Write-Output "`tcopying $filename to $dirShortName";
            #     Copy-Item -path $_.FullName -destination $queue
            # }
            # ----------
        }
        # test the path for each logo size

        for ($i = 0; $i -lt $logoSizesByApplication.length; $i++) {
            if (Get-Member -InputObject $orders.$orderID -name $logoSizesByApplication[$i].name -MemberType Properties) {
                $logoSizesByApplication[$i].value = 0;
                $logoSizesByApplication[$i].value = $orders.$orderID | Select-Object -ExpandProperty $logoSizesByApplication[$i].name 
            }
        }

        for ($i = 0; $i -lt $logoSizesByApplication.Length; $i++) {
            if ($logoSizesByApplication[$i].name -ne "11x6") {
                $space = "";
            }
            else {
                $space = ""
            };
            if ($logoSizesByApplication[$i].value -gt 0) {
                write-host -nonewline "`t"$space $logoSizesByApplication[$i].name":`t"$logoSizesByApplication[$i].value"`n"
                appendLog ($space + $logoSizesByApplication[$i].name + ":`t" + $logoSizesByApplication[$i].value)
            }
        }
    }

    # Start sleep to add delay to keep order forms in the correct positions after printing.
    # Internal/picking slip; should be first, then the external/packing
    start-sleep -Seconds 2

    # find EXTERNAL PACKING SLIP PDF doc with order ID match in filename and print through acrobat

    $pdfPath = Get-ChildItem -path $orderDir -include "SalesOrd_$orderID.pdf" -r | Select-Object -f 1
    if ($null -eq $pdfPath) {
        # chrome "https://www.snap-raise.com/warehouse/reports/all_order_items_packing_slip?order_id=$orderID"
        chrome "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label=Packing+Slip&formnumber=129&trantype=salesord&id=$orderID"
        Write-Output 'downloading All Items Packing Slip PDF...'
        Start-Sleep -seconds 1
        $pdfPath = Get-ChildItem -path $orderDir -include "order-$orderID.pdf" -r;
    }
    $pdfPath | foreach-object {
        start-process -FilePath $_.FullName -Verb Print -PassThru | ForEach-Object { ;
            Start-Sleep 2;
        } | Stop-Process;
    }
    $dump = Get-Content orders.json
    add-content -path "$shareDrive\temp\$user`_orders.json" -value ",$dump"
    # remove-item 'orders.json'
    # Write-Output "`tFiles Sent to Printers Successfully"
    return
}
function LogoScriptWildcarder($unsearchable) {
    if ($unsearchable.split("{|}").length -eq 3) {
        $split = $unsearchable.split("{|}")
        $unsearchable = $split[0] + "*" + $split[2]
    }
    $theReplacers = @("\*\*\*", "\*\*", "track\*and\*field", "track\*&\*field", "swim\*and\*dive", "swim\*&\*dive", "swimming", "volleyball", "basketball")
    $theReplacements = @("*", "*", "track", "track", "swim", "swim", "swim", "volley", "b*ball")
    $searchable = $unsearchable -replace "\|", "*"      # replace pipe
    $searchable = $searchable -replace " ", "*"         # replace whitespace
    $searchable = $searchable -replace "\.", "*"        # replace periods
    # $searchable = $searchable -replace "\W","*"       # replace non-word characters
    $searchable = $searchable -replace "\d"             # replace digits
    for ($i = 0; $i -lt $theReplacers.length; $i++) {
        if ($searchable -match $theReplacers[$i]) {
            $searchable = $searchable -replace $theReplacers[$i], $theReplacements[$i]
        }
    }
    if ($searchable -match "\*$") {
        return $searchable
    }
    else {
        $searchable + '*'
    }
}

function appendLog($textToLog) {
    $logTime = get-date -format "HH:mm:ss"
    add-content -path $logFullName "$logTime`t:`t$textToLog"
}

if ($ID -And $desiredPrinter -And $desiredQueue -And $orderType) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) ($desiredQueue - 1) $orderType
}
Elseif ($ID -And $desiredPrinter -And $desiredQueue) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) ($desiredQueue - 1)
}
Elseif ($ID -And $desiredPrinter) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) 0
}
Else { return }
