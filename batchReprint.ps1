#print reprint requests pulled from slack thorugh powershell
#george pastushok 2021 - georgepastushok@gmail.com

# create parameter to accept values for a printer and reprint type:
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [Alias("p")]
    [ValidateRange(1, 4)]
    [int] $desiredPrinter
)

. $scriptsHome\lib.ps1

$printer = @("Mary-Kate", "Ashley", "Nicole", "Paris", "Rolanda");
$p = $desiredPrinter - 1;
$queue = "C:\ProgramData\Roland DG VersaWorks\VersaWorks\Printers\" + $printer[$p] + "\Input-B\"


#create the file definition
#should be a CSV file converted to PSObject
$rep = Get-Content reprints.csv | ConvertFrom-Csv

# copy the print job header to the queue
Copy-Item $shareDrive\press-reprints.eps $queue
Copy-Item $shareDrive\weeding-masking-reprints.eps $queue

#main loop
foreach ($req in $rep) {
    $orderId = $req.orderId;
    $logoSize = $req.logosize;
    $lookupUrl = "$db_uri`orders/$orderId"
    $order = Invoke-RestMethod -Method 'GET' -Uri "$lookupUrl"
    $response = Get-Response $lookupUrl
    if ($response -eq 200) {
        $fundId = $order.fundraiser_id
        # rep $req.orderId;
        $order
        write-host  "size:`t`t" $req.logosize;
        write-host  "quantity:`t" $req.quantity;
        Write-Host  "error:`t`t" $req.error;
        write-host  "type:`t`t" $req.type;
        # check if the logo size is valid:
        Switch ($logoSize) {
            "digital" { write-host "changing to logo size `"d`" from digital"; $logoSize = "d" }
            "8x4" { write-host "changing to logo size `"d`" from digital"; $logoSize = "d" }
            "digital small" { write-host "changing to logo size `"ds`" from digital small"; $logoSize = "ds" }
            "small" { write-host "changing to logo size `"ds`" from small"; $logoSize = "ds" }
        }
        $logoSize = $logoSize.ToLower();
        # copy requested file to a print queue:
        # write-host "orderid: $orderId, logoSize: $logoSize, fundId: $fundId"
        # write-host "$fundId`_$logoSize.eps"
        $orderLocation = (Get-ChildItem -path "$ShareDrive`AA*" -include "PICKING*$orderId.pdf" -r | Select-Object -f 1).directory
        # $fileLocation = (get-childitem -path "F:\AA*" -include "$fundId`_$logoSize.eps" -r | select -f 1).FullName
        $fileLocation = (get-childitem -path $orderLocation -include "$fundId`_$logoSize.eps" -r | Select-Object -f 1).FullName
        # explorer /select,$filelocation
        # write-host "fileLocation: $fileLocation"
        if ($fileLocation) {
            if ($req.error -eq "b") {
                write-host "Art error, paused to check logos and submit to art team..."
                Pause;
            }
            for ($i = 0; $i -lt $req.quantity; $i++) {
                $index = $i + 1;
                Copy-Item $fileLocation "$queue\$fundId`_$logoSize`_$index.eps"
            }
        }
        else {
            write-host "file $fundId`_$logoSize.eps not found, opening folder location $orderLocation"
            explorer /select,$orderLocation
            Pause;
        }
        if ($req.logoSize -eq "8x4" -Or $req.error -Contains "size") {
            write-host "Resize logo; pausing...";
            Pause;
        }
    } else {
        write-host "order not found in database, check if its a real order on netsuite"
        write-host "https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$id"
}
    # Pause;
}
function pause() {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    write-host "continuing..."
}