#Aliased to yeet
#use options to direct how the files are treated
#
#FOR NETSUITE; FOR SERVER; VERSION 3 -- In Progress
# =====================================================================================
# ======_|\___||____||==\\__||==\\____//\\_____//\\___||==\\__||====__/====\___/====\__
# __||___| \__||____||___\\_||___\\__//__\\___//__\\__||___\\_||_____||___||__||___||__
# __||___||\\_||____||___//_||___//_//____\\_//_______||___//_||_____||_______||_______
# __||___||_\\||____||==//__||==//__\\____//_\\__====_||==//__||====__\====\___\====\__
# __||___||__\ |____||______||__\\___\\__//___\\__//__||__\\__||_____--____||_--____||_
# ======_||___\|____||______||___\\___\\//_____\\//___||___\\_||====_\=====/__\=====/__
# =====================================================================================

[cmdletBinding()]
    param(
#   _____________
    #    Printer \___________________________________________
    #    -p :Select a printer: Moves files to the requested directory
        # Select a printer to sent the files to, Default to q A
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("p")]
        [ValidateRange(1,4)]
        [int] $Printer,
#   ___________
    #    Queue \___________________________________________
        # -q :Select a printer: Moves files to the requested directory
        # Select a printer to sent the files to, Default to q A
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("q")]
        [ValidateRange("a","e")]
        [string] $queue,
#   _____________
#        JobGuid \___________________________________________
#        -jobId : Pass the job ID into this script; should be newly created.
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [String[]] $jobId
    )

clear-content -path $printlist;
write-host "cleared printlist"

# set the queue to default if it is blank
if ($queue) {
    write-host "queue is : $queue"
} else {
    $queue = "a"
}
# Create the names for the folders for the day.
$date = get-date # -Format "MMdd"
$ROOTDIR = split-path $PWD
$rollFile = 'r{0:MMdd}0' -f $date
#$PRNTRDIR = for ($i = 0; $i -lt 4; $i++) {$rollfile + $i;}
$dir = get-location;
#write-output "dir: $dir"
# get the orders.json into a usable format
    # get the orders.json into a POSH object
$ordersJsonPath = get-childitem -path $dir\\* -include 'orders.json' -r
$ordersJson = get-content $ordersJsonPath | convertfrom-json
# create an empty array to fill
# write the array to the console
# displayed as:
# orders: @{6494728=; 6691294=; 6691295=; 6691296=; 6691297=; 6691501=; 6691587=}
write-output "orders: $($ordersJson.order_id)"

# create a guid for the job ID, here to add to the database as soon as possible
#       80dd9be5-7d9c-4a00-af8d-26eb539099db
if (!$jobId) {
    $jobId = (New-Guid).Guid
    Write-Host "created new GUID for the Job ID: $jobId"
}

# declare / initialize empty array for building a table of the orders:
$ordersToTable = @()

# loop through all the order IDs in the $list
# At the end post the Order, Job and Job_Order pair to the DB.
for ($i = 0; $i -lt $ordersJson.length; $i++) {
    if ($ordersJson) {
        $ORDERID = $ordersJson[$i].order_id
        # write-output "order id: $ORDERID"
        $CURRENTORDER = $ordersJson[$i]
        # add property with value username
        $FUNDID = $CURRENTORDER.fundraiser_id
        # write-output "fund id: $FUNDID"
        # add the placed date of the order to the $ORDERSDATERANGE array:
        # $ORDERSDATERANGE += $CURRENTORDER.placedDate
        add-content -path $printlist -value $ORDERID
        # write-host "added $ORDERID to printlist"
        # add the current iterated order to the database
        # Post to orders table:
        # $names = ($orders | Select-Object -f 1 | get-member -type noteProperty | Select-Object -property Name)
        # Write-Output $names.length
        $body = @{
          order_id = $CURRENTORDER.order_id
          sales_order_id = $CURRENTORDER.sales_order_id
          magento_id = $CURRENTORDER.magento_id
          fundraiser_id = $CURRENTORDER.fundraiser_id
          fundraiser_name = $CURRENTORDER.fundraiser_name
          placed_on_date = $CURRENTORDER.placed_on_date
        #   placed_on_date = $(Get-Date ($CURRENTORDER.placed_on_date)).datetime
          date_downloaded = $CURRENTORDER.date_downloaded
        #   date_downloaded = (Get-Date $($CURRENTORDER.date_downloaded.split(' ')[0,1,2,3,4] -Join ' ')).datetime
          date_printed = $null
          order_type = $CURRENTORDER.order_type
          order_notes = $CURRENTORDER.order_notes
          logo_script = $CURRENTORDER.logo_script
          logo_id = $CURRENTORDER.logo_id
          primary_color = $CURRENTORDER.primary_color
          secondary_color = $CURRENTORDER.secondary_color
          logo_count_digital = $CURRENTORDER.logo_count_digital
          logo_count_digital_small = $CURRENTORDER.logo_count_digital_small
          logo_count_sticker = $CURRENTORDER.logo_count_sticker
          logo_count_embroidery = $CURRENTORDER.logo_count_embroidery
          print_user_name = $user
          print_job_id = $jobId[0]
          print_device = $Printer
        } | convertto-Json
        if ($NULL -ne $body) {
            # Write-Output "order Body:`n$body"
            Invoke-RestMethod -Method POST -Uri "$db_uri/orders" -body $body -contentType "application/json" | Out-Null
        } else {
            Write-Output "body is null"
        }
        # Post to job_orders API endpoint:
        $body = @{
          job_id = $jobId[0]
          order_id = $CURRENTORDER.order_id
        } | ConvertTo-Json
        if ($NULL -ne $body) {
            # Write-Output "job_order Body:`n$body"
            Invoke-RestMethod -Method POST -Uri "$db_uri/job_orders" -Body $body -ContentType "application/json" | Out-Null
        } else {
            Write-Output "body is null"
        }
        # The following cases can be made to move/sort the orders in the file system automatically like so:
        # switch $orderType
            # [case] OTF:
                # write-host ...
                # move-item $fundId.eps ../otf/
                # move-item *$orderId.pdf ../otf/
                # 
        # [case] normal order
        if ($Printer -lt 1 -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -ne $true) {
            #Moving files up one directory to the folder for the current week.
            # Write-Host  -foregroundcolor yellow "no options selected: moving orders up one level."
            # copy-item "*$FUNDID*.eps" .. -Force;
            # copy-item "*$ORDERID*.pdf" .. -Force;
            move-item "*$FUNDID*.eps" .. -Force;
            move-item "*$ORDERID*.pdf" .. -Force;
            #remove-item *;
        }
        #[case] Rolanda
        if ($Printer -ne $true -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -eq $true) {
            write-host -foregroundcolor yellow 'sending files to \Rolanda'
            #moves files to the Reorder dir
            # move-item "*$FUNDID*.eps" ..\Rolanda;
            # move-item "*$ORDERID*.pdf" ..\Rolanda;
        }
        # [case] Roll
        if ($Printer -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -ne $true) {
            # moves files to Rolanda dir
            $DESTINATION = "$ROOTDIR\"
            # $DESTINATION
            # move-item "$FUNDID*.eps" $DESTINATION -Force;
            # move-item "*$ORDERID.pdf" $DESTINATION -Force;
            # write-host -foregroundcolor yellow "option roll selected: moving orders to $DESTINATION"
        }
        # Add the current order's data set to the table array:
        $ordersToTable += $CURRENTORDER
    }
}
# create the table and save it to a csv file:
if ((test-path temp.csv) -eq $false) {
    New-Item temp.csv
}
$table = $ordersToTable | Select-Object order_id,fundraiser_id,placed_on_date,fundraiser_name,job_id;
# $table | Format-Table -AutoSize;
$table | Export-Csv temp.csv -NoTypeInformation;
# Start-Process temp.csv -verb print;

$Global:jobId = $jobId
$body = @{
    job_id = $jobId[0]
    date_downloaded = $ordersJson[0].date_downloaded
    date_printed = "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
    print_user = $user_id
    print_device = $Printer
    print_queue = $queue
} | ConvertTo-Json
# Write-Output "job Body:`n$body"
Invoke-RestMethod -Method Post -Uri "$db_uri/jobs/" -body $body -ContentType "application/json" | Out-Null
#   JOB_ORDERS: [
#       {
#         order_id: ID,
#         job_id: UUID
#       }
# ]
# $toAdd = @()
# $toAdd += get-content $DATABASE | convertfrom-json
# $toAdd += $orders
# set-content -path $DATABASE -value ($toAdd | convertto-json)
Write-Output "set content database"

# if ($Printer) {
#     # moves files to requested printer directory
#     $DESTINATION = $PRNTRDIR[$Printer]
#     # Copy-Item "*$FUNDID*.eps" $DESTINATION
#     # copy-item "*$ORDERID*.pdf" $DESTINATION
#     $DESTINATION
#     exit
#     #remove-item *;
#     write-host -foregroundcolor Yellow "sending job to"$DESTINATION
# }
# elseif ($o) {
#     #moves files to the OTF dir
#     move-item "*$FUNDID*.eps" ..\OTF;
#     move-item "*$ORDERID*.pdf" ..\OTF;
#     copy-item 'orders.json' ..;
#     write-host -foregroundcolor yellow 'sending files to \OTF'    
# }
# elseif ($d) {
#     #moves files to the Reorder dir
#     move-item "*$fundid*.eps" ..\Reorder;
#     move-item "*$orderid*.pdf" ..\Reorder;
#     write-host -foregroundcolor yellow 'sending files to \reorder'
# }
# elseif ($x) {
#     #moves files to the Reorder dir
#     move-item "*$fundid*.eps" ..\Rolanda;
#     move-item "*$orderid*.pdf" ..\Rolanda;
#     write-host -foregroundcolor yellow 'sending files to \Rolanda'
# }
# else {
#     #move files up one level in the directory tree to the folder that is made for this week.
#     #Write-Output 'copying files incentives'
#     # move-item "*$FUNDID*.eps" ..;
#     # move-item "*$ORDERID*.pdf" ..;
#     # copy-item 'orders.json' ..;
#     #remove-item *;
# }