#Aliased to yeet
#use options to direct how the files are treated
#
#FOR NETSUITE; VERSION 1

[cmdletBinding()]
    param(
#   _____________
        #Printer \___________________________________________
        #-p :Select a printer: Moves files to the requested directory
        # SElect a printer to sent the files to, Default to q A
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("p")]
        [ValidateRange(1,4)]
        [int] $Printer,
#   _____________
        #OTF     \___________________________________________
        # -o : OTF orders : Moves files to the OTF directory
        # Should be used in conjunction with -p but should still copy_
        # the files to q A while moving the files to the OTF dir
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [switch] $o,
#   _____________
        #ROLANDA \___________________________________________
        # -x : orders printed on rolanda : Moves files to the Rolanda dir
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [switch] $x,
#   _____________
        #Reorder \___________________________________________
        # -d : Reorder/redeux : moves orders to the reorder directory
        # Should be used in conjunction with -p but should still copy_
        # the files to q A while moving the files to the reorder dir
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Switch] $d
    )

clear-content -path $printlist;

# Create the names for the folders for the day.
$date = get-date # -Format "MMdd"
$ROOTDIR = split-path $PWD
$rollFile = 'r{0:MMdd}0' -f $date
#$PRNTRDIR = for ($i = 0; $i -lt 4; $i++) {$rollfile + $i;}
$dir = get-location;
#write-output "dir: $dir"
$orders = get-childitem -path $dir\\* -include 'orders.json' -r
$orders = get-content $orders | convertfrom-json
$toAdd = @()
$toAdd += get-content $DATABASE | convertfrom-json
$toAdd += $orders
set-content -path $DATABASE -value ($toAdd | convertto-json)
write-output "orders: $orders"
$list = $orders | Get-Member
$list = ($list | select-object -property 'Name')
#write-output "list: $list"
for ($i = 4; $i -lt $list.length; $i++) {
    if ($orders) {
        $j = $list[$i] | Select-Object -ExpandProperty 'Name'
        #write-output "j: $j"
        $ORDERID = $orders.$j | select-object -expandproperty 'orderId'
        #write-output "order id: $ORDERID"
        #$ORDERTYPE = $orders.$j | select-object -expandproperty 'orderType'
        #write-output "order type: $ORDERTYPE"
        # $SALESORDERID = $orders.$j | Select-Object -ExpandProperty 'salesOrder'
        $CURRENTORDER = $orders.$j
        $CURRENTORDER.printDate = (Get-Date -Format "ddd MMM dd yyyy HH:mm:ss G\MTK") + " (Pacific Daylight Time)"
        $FUNDID = $orders.$j | select-object -expandproperty 'fundId'
        #write-output "fund id: $FUNDID"
        add-content -path $printlist -value $ORDERID
        # [case] normal order
        if ($Printer -lt 1 -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -ne $true) {
            #Moving files up one directory to the folder for the current week.
            Write-Host  -foregroundcolor yellow "no options selected: moving orders up one level."
            move-item "*$FUNDID*.eps" .. -Force;
            move-item "*$ORDERID*.pdf" .. -Force;
            #remove-item *;
        }
        #[case] OTF
        if ($Printer -ne $true -and $o -eq $true -and $roll -ne $true -and $d -ne $true -and $x -ne $true) {
            Write-Host  -foregroundcolor yellow "option OTF selected: moving to ../OTF";
            #move files ot the OTF directory
            move-item "*$FUNDID*.eps" ..\otf -Force;
            move-item "*$ORDERID*.pdf" ..\otf -Force;
        }
        #[case] Reorder
        if ($Printer -ne $true -and $o -ne $true -and $roll -ne $true -and $d -eq $true -and $x -ne $true) {
            Write-Host  -foregroundcolor yellow "option reorder selected: moving to ../reorder";
            #move files ot the OTF directory
            move-item "*$FUNDID*.eps" ..\Reorder -Force;
            move-item "*$ORDERID*.pdf" ..\Reorder -Force;
        }
        #[case] Rolanda
        if ($Printer -ne $true -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -eq $true) {
            write-host -foregroundcolor yellow 'sending files to \Rolanda'
            #moves files to the Reorder dir
            move-item "*$FUNDID*.eps" ..\Rolanda;
            move-item "*$ORDERID*.pdf" ..\Rolanda;
        }
        # [case] Roll
        if ($Printer -gt 1 -and $o -ne $true -and $roll -ne $true -and $d -ne $true -and $x -ne $true) {
            # moves files to Rolanda dir
            $DESTINATION = "$ROOTDIR\$rollfile$Printer"
            $DESTINATION
            move-item "$FUNDID*.eps" $DESTINATION -Force;
            move-item "*$ORDERID.pdf" $DESTINATION -Force;
            write-host -foregroundcolor yellow "option roll selected: moving orders to $DESTINATION"
        }
    }
}

$toAdd = @()
$toAdd += get-content $DATABASE | convertfrom-json
$toAdd += $orders
set-content -path $DATABASE -value ($toAdd | convertto-json)

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