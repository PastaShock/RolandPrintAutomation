[cmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("printer", "p")]
    [ValidateRange(0, 4)]
    [int] $desiredPrinter,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("type", "t")]
    [switch] $orderType,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("r")]
    [switch] $roll,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [String[]] $jobId,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $verbosity,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $NoPrint,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $NoCopy

)

# create the function to create the job-header
# pass the following values:
#   job-id - a guid thats unique to the set of orders being printed
#   date    -   either the current date-time or the date range of the orders in the orders.json
#   user    -   user name of the person printing the orders
#   printer -   device the job is being sent to
#   queue   -   the device's versaworks queue (to confirm printer settings)
#   orderType   name of types of order

# define $jobId as a global variable to change it out of scope
$Global:jobId = '';

function jobHeaderGen($q) {
    # do i create the header here and pull the info from the orders.json? or do it in the print.ps1?
    # make sure that all variables are accounted for; arrays for printers, queues, users, dates etc
    #   - get placed dates from orders.json of all orders
    $date = @(); # init array for storage of dates of all orders
    $ordersToTable = @() # Create/initialize an array for reformating orders.json

    $ORDERSJSON = (Get-Content .\orders.json | convertfrom-json);
    $ORDERSDATABASE = get-content $DATABASE | convertfrom-json
    $ORDERLIST = ($ORDERSJSON | get-member);
    $ORDERLIST = ($ORDERLIST | Select-Object -property 'Name');
    
    for ($i = 4; $i -lt $ORDERLIST.length; $i++) {
        $ORDER = $ORDERLIST[$i] | Select-Object -expand 'Name';
        # $ORDERID = ($ORDERSJSON.$ORDER | Select-Object -expand 'orderId');
        $CURRENTORDER = $ORDERSJSON.$ORDER;
        $date += $CURRENTORDER.placedDate;
        $orderType = $CURRENTORDER.orderType;
        $jobId = ($ORDERSDATABASE.$ORDER | Select-Object -f 1).JobId;
        $ordersToTable += $CURRENTORDER;
        $Global:jobId = $jobId;
    };
    # take the first and last item from the array and put them in a new array.
    $dateConcat = ($date | Select-Object -f 1), ($date | Select-Object -l 1);
    $dateConcat = $dateConcat -join ' - ';

    # define the current date:
    $currDate = Get-Date;

    # Define the arrays of printers and queues:
    $printer = @(
        'Mary-Kate',
        'Ashley',
        'Nicole',
        'Paris',
        'Rolanda'
    );
    $queue = @(
        'a',
        'b',
        'c',
        'd',
        'e'
    );
    $PRINTDEVICE = $printer[$desiredPrinter - 1];
    $PRINTQUEUE = $queue[$q - 1];

    # set orderType to a prettier string:
    switch ($orderType) {
        "OTK Purchases and Incentives" { $orderType = "Incentive/OTK" }
        "Snap!Store" { $orderType = "Store" }
        "Coach Gear" { $orderType = "Reorders"; $priority = $true}
        "Reorder" { $orderType = "Reorders"; $priority = $true}
        "OTF" { $orderType = "Incentive/OTK" }
        Default { $orderType = "Happy Orders!" }
    };

    # orderstotable should now be full of all the orders and ready to convert to JSON
    $table = $ordersToTable | Select-Object orderId,salesOrder,fundId,fundName,placedDate,logoScript,priColor,secColor,logoId,digital,digiSmall;
    $JSONpayload = $table | ConvertTo-Json
    # I am writing the JSON to a file because I could not get it to cooperate as just a string passed as a variable/object into node
    Set-Content "C:\ps\job-top-sheet\temp.json" $JSONpayload

    # call the following node.js applets: job-header-gen and job-top-sheet
    node 'C:\ps\job-top-sheet\app.js' --jobId="$jobId" --datePlaced="$dateConcat" --dateCurrent="$currDate" --user="$user" --printer="$PRINTDEVICE[$PRINTQUEUE]" --orderType="$orderType" --priority="$priority"
    node 'C:\ps\label_temp - Copy\app.js' --jobId="$jobId" --datePlaced="$dateConcat" --dateCurrent="$currDate" --user="$user" --printer="$PRINTDEVICE[$PRINTQUEUE]" --orderType="$orderType" --priority="$priority"
    Move-Item "C:\ps\job-top-sheet\$Global:jobId-top-sheet.pdf" ..
    Start-Process "..\$Global:jobId-top-sheet.pdf" -verb print
    # copy the file to the print queue:
    $headerPath = "C:\ps\label_temp - Copy\$jobId.pdf"
    while ((test-path $headerPath) -ne $true) {
        Write-Host "$headerPath not available yet, pausing for 1 second..."
        Start-Sleep 1;
    }
    Copy-Item $headerPath "C:\ProgramData\Roland DG VersaWorks\VersaWorks\Printers\$PRINTDEVICE\Input-$PRINTQUEUE\"
}

if ($orderType -ne $true -and $roll -ne $true) {
    #write-output "Case0"
    $q = 1
    jobHeaderGen $q
    if ($verbosity) {
        Write-Host -ForegroundColor Yellow "batchPrint:ln21:debugmode`n`torderType: $orderType`n`troll: $roll`n`tdesiredPrinter: $desiredPrinter`n`tqueue; $q`n`torderType: $orderType`n`tjobId: $Global:jobId"
    }
    if ($NoPrint -and $NoCopy) {
        get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -jobId $Global:jobId $verbosity -noprint -nocopy }
    }
    else {
        get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -jobId $Global:jobId $verbosity }
    }
}
elseif ($roll -ne $true -and $orderType -eq $true) {
    $q = 1
    jobHeaderGen $q
    #write-output "Case1"
    get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -orderType -jobId $Global:jobId $verbosity }
}
elseif ($roll -eq $true -and $orderType -ne $true) {
    #write-output "Case2"
    $q = 3
    jobHeaderGen $q
    get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -jobId $Global:jobId $verbosity }
    $folderDate = get-date -format "MMdd"
    $folderDate += "0$desiredPrinter"
    copy-item 'orders.json' ..\r$folderDate\$Global:jobId.json; 
} 
if (!($verbosity)) {
    # notepad $log
    Move-Item 'orders.json' ..\$Global:jobId.json -Force
    # Copy the job header to the working folder:
    $date = get-date;
    $week = $date.AddDays([DayOfWeek]::Monday - [int]$date.DayOfWeek);
    $week = '{0:yyMMdd}' -f $week;
    $jobDestination = "$shareDrive\AA$week\"
    switch ($roll) {
        $true { $jobDestination += "r$folderDate\" }
        Default {}
    }
    Move-Item "C:\ps\label_temp - Copy\$Global:jobId.pdf" $jobDestination
    notepad $jobDestination\$Global:jobId.json

}


exit
