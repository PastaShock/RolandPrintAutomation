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
        $jobId = ($ORDERSDATABASE.$ORDER).JobId;
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
        "Coach Gear" { $orderType = "Reorders" }
        "Reorder" { $orderType = "Reorders" }
        "OTF" { $orderType = "Incentive/OTK" }
        Default { $orderType = "Happy Orders!" }
    };

    # Write-Output "`$jobId: $jobId"
    # Write-Output "`$dateConcat: $dateConcat"
    # Write-Output "`$currDate: $currDate"
    # Write-Output "`$user: $user"
    # Write-Output "`$printDevice[`$printqueue]: $PRINTDEVICE[$PRINTQUEUE]"

    # call the function via node.js
    node 'C:\ps\label_temp - Copy\app.js' --jobId="$jobId" --datePlaced="$dateConcat" --dateCurrent="$currDate" --user="$user" --printer="$PRINTDEVICE[$PRINTQUEUE]" --orderType="$orderType"
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
    #write-output "Case1"
    get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -orderType -jobId $Global:jobId $verbosity }
}
elseif ($roll -eq $true -and $orderType -ne $true) {
    #write-output "Case2"
    $q = 3
    get-content -path "$printlist" | foreach-object { incentive -i $_ -p $desiredPrinter -q $q -jobId $Global:jobId $verbosity }
    $folderDate = get-date -format "MMdd"
    $folderDate += "0$desiredPrinter"
    copy-item 'orders.json' ..\r$folderDate\$folderDate.json; 
} 
if (!($verbosity)) {
    notepad $log
    Move-Item 'orders.json' ..\$Global:jobId.json -Force
    # Copy the job header to the working folder:
    $date = get-date;
    $week = $date.AddDays([DayOfWeek]::Monday - [int]$date.DayOfWeek);
    $week = '{0:yyMMdd}' -f $week;
    Move-Item "C:\ps\label_temp - Copy\$Global:jobId.pdf" "$shareDrive\AA$week\"

}


exit
