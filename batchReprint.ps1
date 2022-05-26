#print reprint requests pulled from slack thorugh powershell
#george pastushok 2021 - georgepastushok@gmail.com

#create the file definition
#should be a CSV file converted to PSObject
$rep = Get-Content reprints.csv | ConvertFrom-Csv

#main loop
foreach ($req in $rep) {
    rep $req.orderId;
    $orderID = $req.orderId
    write-host  "order:`t`t" $orderID;
    write-host  "size:`t`t" $req.logosize;
    write-host  "quantity:`t" $req.quantity;
    write-host  "notes:`t`t" $req.notes;
    Pause;
}
    function pause() {
        Write-Host -NoNewLine 'Press any key to continue...';
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        write-host "continuing..."
    }