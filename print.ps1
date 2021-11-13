#print an order based on ID entry
#2020 George Pastushok
#
#FOR NETSUITE; VERSION 1

[cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("orderID", "i")]
        #[ValidatePattern("^\d{6}$")]
        [String[]] $ID,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("printer", "p")]
        [ValidateRange(1,4)]
        [int] $desiredPrinter,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("queue", "q")]
        [ValidateRange(1,5)]
        [int] $desiredQueue,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("type", "t")]
        [switch] $orderType
    )

$logDate = get-date -Format "dd-MM-yy"
$logName = "$logdate.txt"
if ($null -eq (get-childitem -path $printLogs -include $logname -r)) {
    new-item -name $logname -path $printLogs
}
$logFullName = "$printLogs\$logName"
$divider = "---------------"
#create a list of order ids from the json file
$orders = Get-ChildItem -path $PWD -include 'orders.json' -r 
if ($null -eq $orders) {return}
$orders = get-content $orders | convertfrom-json
$list = $orders | Get-Member
$list = ($list | select-object -property 'Name')
#$brother = "\\WAREHOUSE-SHIPP\Brother PT-D600"

Add-Type -AssemblyName PresentationCore,PresentationFramework

function PrintIncentiveOrder($orderID, $p, $i, $orderType) {
    $printer = @("Mary-Kate", "Ashley", "Nicole", "Rolanda")
    $Q = @("A", "B", "C", "D", "E")
    $queue = "C:\ProgramData\Roland DG VersaWorks\VersaWorks\Printers\" + $printer[$p] + "\Input-" + $Q[$i]
    #prompt user for ID
    #Find INTERNAL PACKING SLIP PDF with ID match in filename
    $intPath = (Get-ChildItem -path ($shareDrive+"AA*") -include "PICKINGTICKET$orderID.pdf" -r) | Select-Object -f 1
    $orderDir = $intPath.directory.FullName+"\*"
    #prompt user to cancel if the order is OTF
    #$bool = Read-Host -Prompt 'is this order OTF?'
    if ($bool) {return}

    #internal PDF picking slip section------------------------------------
        #if the PDF is not found, get it from the warehouse dash in chrome
    # if ($null -eq $intPath) {
    #     chrome "https://www.snap-raise.com/warehouse/reports/order?order_id=$orderID"
    #     Write-Output "Internal slip was not found. Downloaded Order - $orderID.pdf from Chrome."
    #     Write-Output "retrying.."
    #     start-sleep -seconds 1
    #     $intPath = (Get-ChildItem -path ($shareDrive+"AA*") -include "PICKINGTICKET$orderID.pdf" -r)
    # }
    #print the internal picking slip PDF
    $intPath | foreach-object {
        start-process -FilePath $_.FullName -Verb Print -PassThru | ForEach-Object{
           Start-Sleep 1;
        } | Stop-Process
    }

    #data organization section --------------------------------------------
    appendLog $divider
    $script = $orders.$orderID | Select-Object -expandproperty 'logoScript'
    $fund_id = $orders.$orderID | Select-Object -expandproperty 'fundId'
    $salesID = $orders.$orderID | Select-Object -ExpandProperty 'salesOrder'
    $placedOn = $orders.$orderID | Select-Object -expandproperty 'placedDate'
    # $downloadDate = $orders.$orderID | Select-Object -expandproperty 'downloadDate'
    # $printDate = (Get-Date -Format "ddd MMM dd yyyy HH:mm:ss G\MTK") + " (Pacific Daylight Time)"#$orders.$orderID | Select-Object -expandproperty 'printDate'
    $logoid = $orders.$orderID | Select-Object -expandproperty 'logoId'
    $priColor = $orders.$orderID | Select-Object -expandproperty 'priColor'
    $secColor = $orders.$orderID | Select-Object -expandproperty 'secColor'
    #Logging to console:
    if ($null -eq $script) { write-host -ForegroundColor Red "no logo script!"; return} else {
        Write-Output $orderID
        Write-Output $salesID
        write-Output "`t$script"
        Write-Output "`t$fund_id"
        Write-Output "`t$placedOn"
        #logging to the log file on the HDD
        appendLog ("  id:`t"+$orderID)
        appendLog "fund:`t$fund_id"
        appendLog "date:`t$placedOn"
        #appendLog "dnld:`t$downloadDate"
        #appendLog "prnt:`t$printDate"
        appendLog "text:`t$script"
        appendLog "type:`t$logoId"
        appendLog "prim:`t$priColor"
        appendLog "secd:`t$secColor"
    }
    set-content orders.json ($orders | convertto-json)

    #Setup for printing a package label:
    $escapedScript = $script -replace "\|", ""
    
    node 'C:\ps\label_temp\app.js' --script=$escapedScript --orderid=$orderID --salesOrder=$salesID
    #note: the print call will be later to make up for time it takes for the pdf to generate.

    #search for the logos in the HDD, in relevant directories and move them to the auto-queue for Versaworks

#      WARNING: DUPLICATE ORDERS WILL NOT BE FILTERED OUT!

    if ($script -and $fund_id) {
        $searchResult = Get-ChildItem -path $orderdir -include "$fund_id*.eps" -Recurse

        $searchResult | ForEach-Object {
            $filename = $_.Name
            $dirShortName = "...\" + $printer[$p] + "\Input-" + $Q[$i]
            Write-Output "`tcopying $filename to $dirShortName";
        Copy-Item -path $_.FullName -destination $queue
        }

        #logo sizes obfuscation
        $11x = 0;
        $8x = 0;
        $6x = 0;
        $5x = 0;
        $4x = 0;

        if(get-member -inputobject $orders.$orderID -name 'eleven' -membertype Properties) {
            $11x = [psCustomObject]@{name = "11x6"; value = $orders.$orderID | Select-Object -expandproperty 'eleven'}
        }
        if(get-member -inputobject $orders.$orderID -name 'eight' -membertype Properties) {
            $8x = [psCustomObject]@{name = "8x4"; value = $orders.$orderID | Select-Object -expandproperty 'eight'}
        }
        if(get-member -inputobject $orders.$orderID -name 'six' -membertype Properties) {
            $6x = [psCustomObject]@{name = "6x3"; value = $orders.$orderID | Select-Object -expandproperty 'six'}
        }
        if(get-member -inputobject $orders.$orderID -name 'five' -membertype Properties) {
            $5x = [psCustomObject]@{name = "5x3"; value = $orders.$orderID | Select-Object -expandproperty 'five'}
        }
        if(get-member -inputobject $orders.$orderID -name 'four' -membertype Properties) {
            $4x = [psCustomObject]@{name = "4x3"; value = $orders.$orderID | Select-Object -expandproperty 'four'}
        }

        $logoSizesArray = @($11x, $8x, $6x, $5x, $4x);
        for ($i = 0; $i -lt $logoSizesArray.Length; $i++) {
            if ($logoSizesArray[$i].name -ne "11x6") {
                $space = " ";
                } else {
                    $space = ""
                };
                if ($logoSizesArray[$i].value -gt 0) {
                    write-host -nonewline "`t"$space $logoSizesArray[$i].name":`t"$logoSizesArray[$i].value"`n"
                    appendLog ($space + $logoSizesArray[$i].name + ":`t" + $logoSizesArray[$i].value)
                }
        }
    }
    
    start-sleep -Seconds 2

    #find EXTERNAL PACKING SLIP PDF doc with order ID match in filename and print through acrobat

    $pdfPath = Get-ChildItem -path $orderDir -include "SalesOrd_$orderID.pdf" -r | Select-Object -f 1
    # if ($null -eq $pdfPath) {
    #     chrome "https://www.snap-raise.com/warehouse/reports/all_order_items_packing_slip?order_id=$orderID"
    #     Write-Output 'downloading All Items Packing Slip PDF...'
    #     Start-Sleep -seconds 1
    #     $pdfPath = Get-ChildItem -path $orderDir -include "order-$orderID.pdf" -r;
    # }
    $pdfPath | foreach-object {
        start-process -FilePath $_.FullName -Verb Print -PassThru | ForEach-Object{
           Start-Sleep 2;
        } | Stop-Process
    }
        $dump = Get-Content orders.json
        add-content -path "$shareDrive\temp\$user`_orders.json" -value ",$dump"
        #remove-item 'orders.json'
    Write-Output "`tFiles Sent to Printers Successfully"
    return
}
function LogoScriptWildcarder($unsearchable){
    if ($unsearchable.split("{|}").length -eq 3) {
        $split = $unsearchable.split("{|}")
        $unsearchable = $split[0] + "*" + $split[2]
    }
    $theReplacers = @("\*\*\*","\*\*","track\*and\*field","track\*&\*field","swim\*and\*dive","swim\*&\*dive","swimming","volleyball","basketball")
    $theReplacements = @("*","*","track","track","swim","swim","swim","volley","b*ball")
    $searchable = $unsearchable -replace "\|", "*"      #replace pipe
    $searchable = $searchable -replace " ", "*"         #replace whitespace
    $searchable = $searchable -replace "\.", "*"        #replace periods
    #$searchable = $searchable -replace "\W","*"        #replace non-word characters
    $searchable = $searchable -replace "\d"             #replace digits
    for ($i = 0; $i -lt $theReplacers.length; $i++) {
        if ($searchable -match $theReplacers[$i]) {
            $searchable = $searchable -replace $theReplacers[$i],$theReplacements[$i]
        }
    }
    if ($searchable -match "\*$") {
        return $searchable
    } else {
        $searchable + '*'
    }
}

function appendLog($textToLog) {
    $logTime = get-date -format "HH:mm:ss"
    add-content -path $logFullName "$logTime`t:`t$textToLog"
}

if ($ID -And $desiredPrinter -And $desiredQueue -And $orderType) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) ($desiredQueue - 1) $orderType
} Elseif ($ID -And $desiredPrinter -And $desiredQueue) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) ($desiredQueue - 1)
} Elseif ($ID -And $desiredPrinter) {
    PrintIncentiveOrder $ID ($desiredPrinter - 1) 0
} Else { return }
