# print an order based on ID entry
# 2024 George Pastushok
#
# FOR NETSUITE; VERSION 1.2
# updated to include job header generator

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
    [switch] $orderType,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [String[]] $jobId,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [bool] $verbosity,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $NoPrint,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $NoCopy
)
if ($verbosity) {
    Write-Host -foregroundcolor Yellow "---------- DEBUG/VERBOSE MODE ----------"
}
if ($noPrint) {
    Write-Host -foregroundcolor Yellow "------------- NO PRINTING --------------"
}
if ($noCopy) {
    Write-Host -foregroundcolor Yellow "--------------- NO COPY ----------------"
}
if (!(test-path $printLogs)) {
    mkdir $printLogs
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "created print logs directory"
    }
}
$logDate = get-date -Format "dd-MM-yy"
$logName = "$logdate.txt"
if ($null -eq (get-childitem -path $printLogs -include $logname -r)) {
    new-item -name $logname -path $printLogs
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "created print log for today - $logdate"
    }
}
$logFullName = "$printLogs\$logName"
$divider = "---------------"
# create a list of order ids from the json file
$currentJobOrdersJSON = Get-ChildItem -path $PWD -include 'orders.json' -r 
if ($verbosity) {
    Write-Host -ForegroundColor Yellow "Imported orders from orders.json"
}
if ($null -eq $currentJobOrdersJSON) {
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "Orders.json is empty or does not exist"
    }
    return;
}
$currentJobOrders = get-content $currentJobOrdersJSON | convertfrom-json
if ($verbosity) {
    Write-Host -ForegroundColor Yellow "Converted data from orders.json into a PSObject"
}
# --------------------------------------------------------------------------------------
# REMOVE ALL REFERENCES TO OLD DATABASE FILE ( $orders )

# $orders = (Get-Content $DATABASE | convertfrom-json)
# if ($verbosity) {
#     Write-Host -ForegroundColor Yellow "Converted data from $database into a PSObject"
# }
# --------------------------------------------------------------------------------------
# REMOVE ALL REFERENCES TO LIST VARIABLE ( $list )

# $list = $currentJobOrders | Get-Member
# $list = ($list | select-object -property 'Name')

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
    [Logos]::new('digital_small', 0 ),
    [Logos]::new('embroidered', 0 ),
    [Logos]::new('sticker', 0 ),
    [Logos]::new('banner', 0 )
)

function PrintIncentiveOrder($orderID, $p, $i, $orderType) {
    $printer = @("Mary-Kate", "Ashley", "Nicole", "Paris", "Rolanda")
    $Q = @("A", "B", "C", "D", "E")
    $queue = "C:\ProgramData\Roland DG VersaWorks\VersaWorks\Printers\" + $printer[$p] + "\Input-" + $Q[$i]
    # prompt user for ID
    $username = $user.split(' ')[0]
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
    if (!($NoCopy)) {
        $intPath | foreach-object {
            start-process -FilePath $_.FullName -Verb PrintTo("$username`sBrother") -PassThru | Out-Null
        }
    }

    # data assignment and logging section ------------------------------------------
    if (!($verbosity)) {
        appendLog $divider
    }
    # ------------------------------------------------------------------------------
    # A different method of reffering to the order from the orders.json file must be
    # used here.
    # OLD: $currentJobOrders.$orderID
    # NEW: $order = $currentJobOrder | where -property 'order_id' -eq $orderID
    # 
    # Thus when pulling information from the object, just refer to the key name
    # ie: $order.logo_script
    # if ( [bool](($currentJobOrders.$orderID).PSObject.properties.name -match 'logo_script') ) {
    #     $script = $currentJobOrders.$orderID | Select-Object -ExpandProperty 'logo_script'
    # }
    # The properties in if/else statements are not required and are set up like this to do error catching
    $order = $currentJobOrders | Where-Object -property 'order_id' -eq $orderID
    if ( $order.logo_script ) {
        $script = $order.logo_script
    }
    else {
        $script = $null
    }
    if ( $order.magento_id ) {
        $script = $order.magento_id
    }
    else {
        $magentoId = $null
    }
    if ( $order.logo_id ) {
        $logoId = $order.logo_id
    }
    else {
        $logoId = $null
    }
    if ( $order.primary_color ) {
        $priColor = $order.primary_color
    }
    else {
        $priColor = $null
    }
    if ( $order.secondary_color ) {
        $secColor = $order.secondary_color
    }
    else {
        $secColor = $null
    }
    # The following properties are required and should always be included with order data unless something has gone terribly wrong
    # $fund_id = $currentJobOrders.$orderID | Select-Object -ExpandProperty 'fundraiser_id'
    $fund_id = $order.fundraiser_id
    $salesID = $order.sales_order_id
    $placedOn = $order.placed_on_date

    # Add which printer the order was printed to the orders JSON file
    # set a variable to the value of $printer[$p]
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "printer: "$printer[$p]
    }
    $selectedPrinter = $printer[$p]
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "orderId: "$orderID
        Write-Host -ForegroundColor Yellow "adding property: Printer with value $($printer[$p]) $($Q[$i])"
    }
    # replace $orders ( json db file ) reference with either db api reference or other.
    # The following is just a check to print the existing order information into the
    # console should the order already be printed. This can be removed.
    # otherwise it should invoke-restMethod to the api
    # $currentOrder = try {
    #     Invoke-RestMethod -Method GET -uri "$database/orders/$orderId"
    # }
    # catch {
    #     # order doesn't exist in the db
    #     Write-Output "order doesn't exist on the db, please fix"
    #     exit
    # }
    # if ($verbosity) {
    #     Write-Host -ForegroundColor Yellow "Order info from `$orders:";
    # }
    # --------------------------------------------------------------------------
    # The following adds a printer ( print_device ) key value pair to the row
    # This is redundant
    # $currentOrder | ForEach-Object {
    #     if (($null -ne $_) -And ($null -eq $_.Printer)) {
    #         $_ | add-member -notepropertyname Printer -notepropertyvalue $selectedPrinter 
    #     } 
    # }
    # if ($verbosity) {
    #     Write-Host -ForegroundColor Yellow "Added printer info to order in the DB PSObject";
    # }
    # $currentOrder | Add-Member -NotePropertyName Printer -NotePropertyValue $selectedPrinter

    # Logging to console:
    # if ($null -eq $script) { write-host -ForegroundColor Red "no logo script!"; return } else {
    # Write-Output $currentJobOrders.$orderID
    # Write-Output $orderID
    # Write-Output $salesID
    # write-Output "`t$script"
    # Write-Output "`t$fund_id"
    # Write-Output "`t$placedOn"
    # # logging to the log file on the HDD
    if (!($verbosity)) {
        appendLog ("  id:`t" + $orderID)
        appendLog "fund:`t$fund_id"
        appendLog "date:`t$placedOn"
        # appendLog "dnld:`t$downloadDate"
        # appendLog "prnt:`t$printDate"
        appendLog "text:`t$script"
        appendLog "type:`t$logoId"
        appendLog "prim:`t$priColor"
        appendLog "secd:`t$secColor"
        appendLog "prnt: `t$selectedPrinter"
    }
    # }
    $order

    # This is no longer necessary
    # if ($verbosity) {
    #     Write-Host -ForegroundColor Yellow "Converting `$currentJobOrders to JSON";
    # }
    # set-content orders.json ($currentJobOrders | convertto-json)
    
    # Setup for printing a package label:
    $escapedScript = $script -replace "\|", ""
    
    if (!($NoPrint)) {
        node 'C:\ps\label_temp\app.js' --script=$escapedScript --orderid=$orderID --salesOrder=$salesID --magentoId=$magentoId --fundraiserId=$fund_id
    }
    # note: the print call will be later to make up for time it takes for the pdf to generate.

    # search for the logos in the HDD, in relevant directories and move them to the auto-queue for Versaworks

    #      WARNING: DUPLICATE ORDERS WILL NOT BE FILTERED OUT!

    if ($fund_id) {
        # ----------
        # reconfigure above script to copy specific logo sizes to their respective queues
        $dirShortName = "...\" + $printer[$p] + "\Input-" + $Q[$i];
        # $order = $currentJobOrders.$orderID
        if ($Q[$i] -ne "C") {
            # ----- Digital ------
            if ($order.logo_count_digital) {
                $logoFileName = $fund_id + "*_d.eps"
                $test = Test-Path ..\$logoFileName;
                if ($test) {
                    $numLogos = $order.logo_count_digital
                    Write-Output "`tcopying $logoFileName to $dirShortName $numLogos times";
                    for ($j = 0; $j -lt $order.logo_count_digital; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_d_$index.eps"
                        if (!($NoCopy)) {
                            copy-item -Path ..\$logoFileName -Destination $destination;
                            if ($verbosity) { Write-Host -ForegroundColor Yellow "`tcopy #$($j)" }
                            Start-Sleep -Milliseconds 1000
                        }
                    }
                }
                else {
                    if (!($verbosity)) {
                        masterErrorLog "$orderID, Missing Digital"
                    }
                }
            }
            # ----- Digital Small ------
            if ($order.logo_count_digital_small) {
                $logoFileName = $fund_id + "*_ds.eps"
                $test = Test-Path ..\$logoFileName;
                if ($test) {
                    $numLogos = $order.logo_count_digital_small
                    Write-Output "`tcopying $logoFileName to $dirShortName $numLogos times";
                    for ($j = 0; $j -lt $order.logo_count_digital_small; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_ds_$index.eps"
                        if (!($NoCopy)) {
                            copy-item -Path ..\$logoFileName -Destination $destination;
                            if ($verbosity) { Write-Host -ForegroundColor Yellow "`tcopy #$($j)" }
                            Start-Sleep -Milliseconds 1000
                        }
                    }
                }
                else {
                    if (!($verbosity)) {
                        masterErrorLog "$orderID, Missing Digital Small"
                    }
                }
            }
            # ----------
        }
        else {
            $rollDirName = "r" + (Get-Date -format "MMdd") + "0" + ($p + 1)
            Write-Output "roll mode; dest: $rolldirname"
            if ($order.logo_count_digital) {
                $logoFileName = $fund_id + "*_d.eps"
                $test = Test-Path ..\$rollDirName\$logoFileName;
                $test
                if ($test) {
                    $numLogos = $order.logo_count_digital
                    for ($j = 0; $j -lt $order.logo_count_digital; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_d_$index.eps"
                        if (!($NoCopy)) {
                            copy-item -Path ..\$rollDirName\$logoFileName -Destination $destination;
                            Start-Sleep -Milliseconds 1000
                        }
                    }
                    Write-Output "`tcopying $logoFileName to $dirShortName";
                    # $destination = "$queue\$fund_id`_d.eps"
                }
                else {
                    if (!($verbosity)) {
                        masterErrorLog "$orderID, Missing Digital"
                    }
                }
            }
            # ----- Digital Small ------
            if ($order.logo_count_digital_small) {
                $logoFileName = $fund_id + "*_ds.eps"
                $test = Test-Path ..\$rollDirName\$logoFileName;
                if ($test) {
                    $numLogos = $order.logo_count_digital_small
                    for ($j = 0; $j -lt $order.logo_count_digital_small; $j++) {
                        $index = $j + 1
                        $destination = "$queue\$fund_id`_ds_$index.eps"
                        if (!($NoCopy)) {
                            copy-item -Path ..\$rollDirName\$logoFileName -Destination $destination;
                            Start-Sleep -Milliseconds 1000
                        }
                    }
                    Write-Output "`tcopying $logoFileName to $dirShortName";
                    # $destination = "$queue\$fund_id`_ds.eps"
                }
                else {
                    if (!($verbosity)) {
                        masterErrorLog "$orderID, Missing Digital Small"
                    }
                }
            }
        }
        # this is all now redundant since I started printing the whole order object in the console; but I need the appendLog call here. 
        for ($i = 0; $i -lt $logoSizesByApplication.length; $i++) {
            if (Get-Member -InputObject $order -name "logo_count_$($logoSizesByApplication[$i].name)" -MemberType Properties) {
                $logoSizesByApplication[$i].value = 0;
                $logoSizesByApplication[$i].value = $order | Select-Object -ExpandProperty "logo_count_$($logoSizesByApplication[$i].name)" 
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
                # write-host -nonewline "`t"$space $logoSizesByApplication[$i].name":`t"$logoSizesByApplication[$i].value"`n"
                appendLog ($space + $logoSizesByApplication[$i].name + ":`t" + $logoSizesByApplication[$i].value)
            }
        }
        Write-Output "`tFiles Sent to Printers Successfully"
    }
    else {
        Write-Output "Fundraiser ID not valid! $($fund_id)"
    }

    # Start sleep to add delay to keep order forms in the correct positions after printing.
    # Internal/picking slip; should be first, then the external/packing
    if (!($NoCopy)) {
        start-sleep -Seconds 2
    }

    # find EXTERNAL PACKING SLIP PDF doc with order ID match in filename and print through acrobat

    $pdfPath = Get-ChildItem -path $orderDir -include "SalesOrd_$orderID.pdf" -r | Select-Object -f 1
    if ($null -eq $pdfPath) {
        # chrome "https://www.snap-raise.com/warehouse/reports/all_order_items_packing_slip?order_id=$orderID"
        chrome "https://4766534.app.netsuite.com/app/accounting/print/hotprint.nl?regular=T&sethotprinter=T&label=Packing+Slip&formnumber=129&trantype=salesord&id=$orderID"
        Write-Output 'downloading All Items Packing Slip PDF...'
        Start-Sleep -seconds 2
        $pdfPath = Get-ChildItem -path $orderDir -include "order-$orderID.pdf" -r;
    }
    if (!($NoPrint)) {
        $pdfPath | foreach-object {
            start-process -FilePath $_.FullName -Verb PrintTo("$username`sBrother") -PassThru | Out-Null
        }
    }
    # $dump = Get-Content orders.json
    # add-content -path "$shareDrive\temp\$user`_orders.json" -value ",$dump"
    # remove-item 'orders.json'
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

# write the DB with updated information
# if (!($verbosity)) {
#     Set-Content -Path $DATABASE -Value ($orders | ConvertTo-Json)
# }
