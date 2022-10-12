#print reprint requests pulled from slack thorugh powershell
#george pastushok 2021 - georgepastushok@gmail.com

#create the file definition
#should be a CSV file converted to PSObject
$rep = Get-Content reprints.csv | ConvertFrom-Csv

#main loop
foreach ($req in $rep) {
    rep $req.orderId;
    write-host  "size:`t`t" $req.logosize;
    write-host  "quantity:`t" $req.quantity;
    Write-Host  "error:`t`t" $req.error;
    write-host  "type:`t`t" $req.type;
    Pause;
}
    function pause() {
        Write-Host -NoNewLine 'Press any key to continue...';
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        write-host "continuing..."
    }