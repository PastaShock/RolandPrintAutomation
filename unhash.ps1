# script to remove UUID, prepended text and appended text to logo file names.
# george pastushok 2019-2022

function unUUID($filename) {
    # find the files that match the UUID pattern
    $uuidPattern = '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}.eps';
    $a = get-childitem -include "*.eps" -r

    for ($i = 0; $i -lt $a.count; $i++) {
        $newName = $a[$i].name.substring(0, $a[$i].BaseName.length - 37) + '.eps'
        if (Test-Path $newName) {
            Write-Output "`t deleting file $a[$i].name"
            Remove-Item $a[$i].name
        }
        else {
            Write-Output "`t renaming file: $newName"
            $a[$i] | rename-item -newname { $newName }
        }
    }
}

# define function to take a filename and rename it/trim off excess text
function renameRegex($filename) {
    # ^(order_design_\d{5}-)*(\d{6}_[dsx0-9]+)([A-z0-9]+)?(-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?([ ()0-9]+)?(.eps)
    return $filename.name -replace "^(order_design_\d{4,6}-)*((\d{5,7}|[A-z0-9\-\&'\#~ ]+)_[dsx0-9]+)([A-z0-9\-\&'\#~]+)?(-)?([ ()0-9]+)?(.eps)", '$2$7'
    # return $filename.name -replace "^(?:[A-z_0-9-]+)(\d{6}_[ds]+)( \(\d{1,2}\))?", '$1'
}

# $c = Get-ChildItem | Where-Object { $_.Name -match "\(*\).eps" }
# for ($i = 0; $i -lt $c.count; $i++) {
#     $oldName = $c[$i] -split " "
#     $newName = $oldName[0] + ".eps"
#     $destination = "$pwd\$newName"
#     Move-Item $c[$i].Name -Destination $destination -Force
# }

# the matching regex should look for 
# ^[order_design_\d{5}-]+(\d{5}_[ds]+)( \(\d{1,2}\))?.eps
# or:
# ^(order_design_\d{5}-)*(\d{6}_[dsx0-9]+)([A-z0-9]+)?(-[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12})?([ ()0-9]+)?(.eps)

# Create a script that cycles through the orders.json and finds all fund IDs and checks if they're here:
function checkLogos() {
    $workingDir = $pwd.path
    $ordersList = get-content orders.json | convertfrom-json
    $ordersIndex = @($ordersList | Get-Member | Select-Object -Property 'name')
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
                Write-Host "✅ URL is valid, downloading file..." -ForegroundColor "green"
                downloadFile $URI $logoname $workingDir
            }
            {$_ -ge 400 -and $_ -le 499} {
                Write-Host "`n🤦file doesn't exist, submit ticket to Art Team" -ForegroundColor "red"
                Write-Host "url`t     : https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$($order.orderId)" -NoNewline
                $order | Format-List
                Write-Host "S3url`t     : $URI`n"
                Pause
            }
            {$_ -ge 500 -and $_ -le 599} {
                Write-Host "💣 server error, try again later" -ForegroundColor "red"
            }
            Default {
                Write-Host "☠️ something has gone terribly wrong, sorry." -ForegroundColor "red"
            }
        }
    }
    
}

function downloadFile($URI,$fileName,$directory) {
    Invoke-WebRequest -URI $URI -OutFile "$directory\$fileName"
}

$b = Get-ChildItem -include '*.eps' -r; # | Where-Object { $_.Name -match "order_design_\d{4,5}-*" }
for ($i = 0; $i -lt $b.count; $i++) {
    # write-output ($b[$i]);
    # for ($j = 1; $j -lt $b.count; $j++) {
    $newName = renameRegex($b[$i]);
    # write-output "newName = $newName";
    # $newName += $oldName[$j];
    # }
    #pattern = order_design_{4-6 digits}-{fundId}_{logoSize}_{logoScript}
    # Test-Path $newname;
    # $newName -ne $b[$i].name;
    if ($newName -eq "") { return }
    if ((Test-Path $newName) -and ($newName -ne $b[$i].name)) {
        # Write-Output "`t deleting file $newName`n"
        # Write-Output "newName: $newName"
        # Write-Output "b[i]: $b[$i].name"
        # Write-Host -NoNewLine 'Press any key to continue...';
        # $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        Remove-Item $b[$i]
    }
    else {
        if ($newName -eq $b[$i]) { return }
        # Write-Output "`t renaming file: $newName"
        # Write-Host -NoNewLine 'Press any key to continue...';
        # $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        $b[$i] | rename-item -newname { $newName }
    }
}

checkLogos

# copy all PNGs to the embroidery digitizing queue:
move-item "*.png" "$ShareDrive`embroidery\PNGs\" -force

Remove-Item "*(*).pdf"
Remove-Item "*(*).json"
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_20" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_7C" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "26" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_" , ""}

