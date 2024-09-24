function LogoScriptWildcarder($unsearchable){
    if ($unsearchable.split("{|}").length -eq 3) {
        $split = $unsearchable.split("{|}")
        $unsearchable = $split[0] + "*" + $split[2]
    }
    $theReplacers = @("\*\*\*","\*\*","track\*and\*field","track\*&\*field","swim\*and\*dive","swim\*&\*dive","swimming","volleyball","basketball")
    $theReplacements = @("*","*","track","track","swim","swim","swim","volley","b*ball")
    $searchable = $unsearchable -replace "\|", "*"      #replace pipe
    $searchable = $searchable -replace " ", "*"         #replace whitespace
    $searchable = $searchable -replace "\.", "*"        #replace periods
    #$searchable = $searchable -replace "\W","*"        #replace non-word characters
    #$searchable = $searchable -replace "\d"             #replace digits
    for ($i = 0; $i -lt $theReplacers.length; $i++) {
        if ($searchable -match $theReplacers[$i]) {
            $searchable = $searchable -replace $theReplacers[$i],$theReplacements[$i]
        }
    }
    if ($searchable -match "\*$") {
        return $searchable
    } else {
        $searchable + '*'
    }
}

function Get-Response($URL) {
    # this should be converted to invoke rest method
    $result = Invoke-WebRequest -Uri $URL;
    $res = $(
        try {
            $result.BaseResponse.StatusCode.Value__;
        } catch {
            $_.Exception.Response.StatusCode.Value__;
        }
    )
    switch ($res) {
            200 {
                write-host "status: $res ✅" -ForegroundColor "green"
            }
            {$_ -ge 400 -and $_ -le 499} {
                write-host "status: $res ☠️ file not found" -ForegroundColor "red"
            }
            {$_ -ge 500 -and $_ -le 599} {
                write-host "status: $res 💣 server error, try again later" -ForegroundColor "red"
            }
            Default {
                write-host "status: $res ☠️ something has gone terribly wrong, sorry." -ForegroundColor "red"
            }
    }
    return $result
}

function Spaces($key) {
    if ($key.length -gt 50) {
        Write-Host "whoops, key is too long!"
    } else {
        $keySpace = 32 - $key.length
        for ($i = 0; $i -lt $keySpace; $i++) {
            $spaces += " "
        }
        return $spaces -join ""
    }
}

function Add-LogoUrls($response) {
    # set a var as the order response obj
    try {
        $orderObj = $response.content | ConvertFrom-Json
    }
    catch {
        # error
    }
    # create an array of key names from that obj
    try {
        $keys = ($orderObj | Get-Member -MemberType NoteProperty | Select-Object Name)
    }
    catch {
        # error
    }
    # set a fund Id var for a shortcut
    $fund_id = $orderObj.fundraiser_id
    # set a var for evenly spacing the : 50chars from the left
    $retArr = @()
    # loop through all keys
    for ($i = 0; $i -lt $keys.length; $i++) {
        # SC: key
        $key = $keys[$i].name;
        # SC: value
        $value = $orderObj.$key
        $spaces = Spaces $key
        # print to the console the key name and three tabs w/o a \n
        # Write-Host -NoNewline "$($key)$($spaces):" -ForegroundColor Green
        # get the names for logo count to get the logo abbreviation ( d, ds )
        if ($key.split('_') -contains "count") {
            $logo = $key.split('_');
            $abb1 = $logo[2][0];
            if ($logo[3]) {
                $abb2 = $logo[3][0];
            }
            $logoAbb = $abb1 + $abb2;
            # $value = "$value`thttps://snapraiselogos.s3.us-west-1.amazonaws.com/Warehouse-Logos/$($fund_id)_$logoAbb.eps"
            $value = "https://snapraiselogos.s3.us-west-1.amazonaws.com/Warehouse-Logos/$($fund_id)_$logoAbb.eps"
            $logo = $abb1 = $abb2 = '';
            # write-host "`t$($value)" -ForegroundColor White
            $retArr += $value
        };
    };
    return $retArr
}

function verbosity($level, $script, $function, $log) {
    $logAppend = "[$(Get-Date -Format "dd-MM-yyyy hh:mm:ss")] "
    switch ($level) {
        { $PSItem -ge 4 }
        { $logAppend += " level: $($level)" }
        { $PSItem -ge 3 }
        { $logAppend += " function: $($function)"}
        { $PSItem -ge 2 }
        { $logAppend += " script: $($script)"}
        { $PSItem -ge 1 }
        { $logAppend += " log: $($log)"}
        Default {}
    }
    Write-Host $logAppend -ForegroundColor Yellow
}