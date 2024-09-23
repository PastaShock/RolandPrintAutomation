# script to remove UUID, prepended text and appended text to logo file names.
# george pastushok 2019-2024

# define function to take a filename and rename it/trim off excess text
function renameRegex($filename) {
    # ^(order_design_\d{5}-)*(\d{6}_[dsx0-9]+)([A-z0-9]+)?(-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?([ ()0-9]+)?(.eps)
    # return $filename.name -replace "^(?:[A-z_0-9-]+)(\d{6}_[ds]+)( \(\d{1,2}\))?", '$1'
    # return $filename.name -replace "^(order_design_\d{4,6}-)*((\d{5,7}|[A-z0-9\-\&'\#~ ]+)_[dsx0-9]+)([A-z0-9\-\&'\#~]+)?(-)?([ ()0-9]+)?(.eps)", '$2$7'
    # New method to accomodate for backprinting logos and to remove legacy file naming conventions:
    return $filename.name -replace "^(order_design_\d{6}-)*(\d{6,7}_)(([ds]*)|([A-z_ ]+))(\.eps)$", '$2$3$6'

}

# Create a script that cycles through the orders.json and finds all fund IDs and checks if they're here:
function checkLogos() {
    $workingDir = $pwd.path
    $ordersIndex = get-content orders.json | convertfrom-json
    # $ordersIndex = @($ordersList | Get-Member | Select-Object -Property 'name')
    for ($i = 4; $i -lt $ordersIndex.length; $i++) {
        $order = $ordersList.$($ordersIndex[$i].name)
        if ($order.digital) {
            $logoSize = "d"
            $logoname = "$($order.fundId)_$logoSize.eps"
            logoDownload $logoname $workingDir
        }
        if ($order.digiSmall) {
            $logoSize = "ds"
            $logoname = "$($order.fundId)_$logoSize.eps"
            logoDownload $logoname $workingDir
        }
    }
}

function logoDownload($logoname, $workingDir) {
    Write-Host "checking logo: $logoname`t::`t$(test-path $logoname)"
    if (!$(test-path $logoname)) {
        $URI = "https://snapraiselogos.s3.us-west-1.amazonaws.com/Warehouse-Logos/$logoname"
        $RESPONSE = $(
            try {
                $res = Invoke-WebRequest -Uri $URI;
                $res.BaseResponse.StatusCode.Value__;
            } catch {
                $_.Exception.Response.StatusCode.Value__
            }
        )
        switch ($RESPONSE) {
            200 {
                Write-Host "`❎ URL is valid, downloading file..." -ForegroundColor "green"
                downloadFile $URI $logoname $workingDir
            }
            {$_ -ge 400 -and $_ -le 499} {
                Write-Host "🤦file doesn't exist, submit ticket to Art Team" -ForegroundColor "red"
                Write-Host "url`t     : https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$($order.orderId)" -NoNewline
                $order | Format-List
                Write-Host "S3url`t     : $URI`n"
                Pause
            }
            {$_ -ge 500 -and $_ -le 599} {
                Write-Host "⚡ server error, try again later" -ForegroundColor "red"
            }
            Default {
                Write-Host "☠ something has gone terribly wrong, sorry." -ForegroundColor "red"
            }
        }
    }
    
}

function downloadFile($URI,$fileName,$directory) {
    Invoke-WebRequest -URI $URI -OutFile "$directory\$fileName"
}

function deleteBrokenPickSlips() {
    $pickSlipList = Get-ChildItem -include PICK*.pdf -r;
    $pickSlipList | ForEach-Object {
        write-host "checking file $($_.name) $($_.length)";
        if (($_.Length -lt 81000) -and ($_.length -gt 76000)) {
            write-host "deleting ${$_.fullName} :: invalid filesize : ${$_.length}"
            remove-item $_.FullName
        }
    }
}

$b = Get-ChildItem -include '*.eps' -r;
for ($i = 0; $i -lt $b.count; $i++) {
    $newName = renameRegex($b[$i]);
    if ($newName -eq "") { return }
    if ((Test-Path $newName) -and ($newName -ne $b[$i].name)) {
        Remove-Item $b[$i]
    }
    else {
        if ($newName -eq $b[$i]) { return }
        $b[$i] | rename-item -newname { $newName }
    }
}

deleteBrokenPickSlips

checkLogos

# copy all PNGs to the embroidery digitizing queue:
move-item "*.png" "$ShareDrive`embroidery\PNGs\" -force

Remove-Item "*(*).pdf"
Remove-Item "*(*).json"
