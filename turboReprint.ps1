﻿#created by George Pastushok september 16th 2019
#Variable "declarations" for changing out all instances of the variables for clarity.
#$criteria                  #variable passed through various functions
#$PackingSlip               #longform string of the location of the excel packing slip that was found in the search.
#$script                    #logo script field from excel packing slip, string
#$searchable                #$script with asterisks in place of spaces and pipes, string
#$refind                    #directory containing the packing slip, string
#$logoSearch                #search result of logo script
#$logoFile                  #first object in $logoSearch
#$rval                      #return value for orderFinder function
#$ScriptSearch              #get-childitem search by logo script for logo file
#$open                      #boolean test value passed into a function to check wether it should open excel or not.
#stop                       #boolean operator to set a functional stop to the script should another branch of the script take precedence

[cmdletbinding()]
Param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("orderID", "i")]
    #[ValidateRange(9999,999999)]
    [ValidatePattern("^\d{7,12}$")]
    [String[]] $ID,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("OF", "o", "PackingSlip")]
    #[ValidatePattern("^\d{5}$")]
    [switch] $OrderForm,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [Alias("logo", "script", "text", "l", "s")]
    [switch] $SearchForScript,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [Alias("snapshop")]
    [switch] $Shop,
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [Alias("Archive", "h", "a")]
    [switch] $history,
    #get order id and get /process on order
    [Parameter(Mandatory = $false, ValueFromPipeline = $false)]
    [switch] $status,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [Alias("google", "g")]
    [string] $share,
    # set verbosity of script
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [switch] $v
)

. $scriptsHome\lib.ps1

$FolderRange = ($shareDrive + "AA*")

# make get req to db to get order information in global scope:
function LogoFinder($criteria) {
    #placeholder If conditional
    if ($criteria.statusCode -eq 200) {
        $ORDER = $criteria.content | convertfrom-JSON
        #find all ordersIds that match search criteria
        # $PackingSlip = OrderFinder $criteria $false
        $estFileLocation = [DateTime]($ORDER.date_printed | get-date)
        $week = $estFileLocation.AddDays([DayOfWeek]::Monday - [int]$estFileLocation.DayOfWeek)
        $week = '{0:yyMMdd}' -f $week
        if ($week) {
            # $ORDER = $ORDERS.$criteria | Select-Object -f 1
            # $script = $ORDER.logoScript
            $fund_id = $ORDER.fundraiser_id
            if ($v) {
                Write-Host -foregroundcolor Yellow "`$fund_id: $fund_id"
            }
            # $placedOn = $Order.placedDate
            # $color = "DarkRed"
            $conColor = "Green"
            # write-host "`tOrder ID:`t" -nonewline
            # write-host -foregroundcolor $color "$criteria`t`t" -nonewline
            # write-host "Fund ID: " -nonewline
            # write-host -foregroundcolor $color "$fund_id"
            # write-host "`tLogo Script:`t" -nonewline
            # write-host -foregroundcolor $color "$script"
            # write-host "`tPlaced On:`t" -nonewline
            # write-host -foregroundcolor $color "$placedOn"
            Write-Output $ORDER
            # Add-LogoUrls $criteria
            write-host "https://snapraiselogos.s3.us-west-1.amazonaws.com/PrinterLogos/$fund_id`_d.png"
            #$searchScript = LogoScriptWildcarder $script
            # $refind = (get-item $PackingSlip).Directory.FullName
            $refind = "$shareDrive`AA$week"
            if ($v) {
                Write-Host -ForegroundColor Yellow "`$refind: $refind"
            }
            #$logoSearch = Get-childitem -path "$refind" -include ("*" + $searchScript) -ErrorAction SilentlyContinue -depth 0
            $logoSearch = Get-childitem -path "$refind\*" -include "$fund_id*.eps" -Recurse
            if ($v) {
                Write-Host -ForegroundColor Yellow "`$logoSearch: $logoSearch"
            }
            #trim line endings and leading and or trailing zeroes.
            write-host -foregroundcolor $conColor "`tOrder "$ORDER.order_id" is located at: "($refind.trim("\`n"))""
            $logoFile = $logoSearch | Select-Object -f 1
            # $logoFile = $logoFile -replace ' ', '` '
            Add-LogoUrls $criteria
            if ($v) {
                write-host -ForegroundColor Yellow "`$logoFile: $logoFile`n`$logoFile.fullname: $($logoFile.FullName)"
            }
            If ($null -eq $logoFile) {
                set-clipboard -value $refind
                explorer $refind
            }
            else {
                $logoFile = $logoFile.FullName
                explorer "/select,$logoFile"
            }
        }
        else {
            write-host "`tsearch for "$ORDER.order_id" returned nothing"
            Write-Host "`topening order in Chrome..."
            chrome "https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$ID&whence="
            #chrome "https://www.snap-raise.com/orders/$ID/process"
            return
        }
        ## function to close all com objects
        #function ReleaseRef ($ref) {
        #([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0 )#| out-null)
        #[System.GC]::Collect() #| out-null
        #[System.GC]::WaitForPendingFinalizers() #| out-null
        #}
        #if ($stop) {
        #return
        #}
        ## close all object references
        #$excel.Quit
        #ReleaseRef($worksheet) | out-null
        #ReleaseRef($workbook) | out-null
        #ReleaseRef($excel) | out-null
        #End process because closing obj refs doesnt stop excel from opening a lot of processes
        #$excelProc = get-process -name excel
        #if ($excelProc.length -gt 4) {
        #stop-process -Id ($excelProc | sort-object StartTime -descending | select-object -f 1).Id
        #Write-Host "`textra excel processes were stopped."
        #}
    } else {
        write-host "order not found in database, check if its a real order on netsuite"
        write-host "https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$id"
    }
}

function OrderFinder($ID, $open) {
    If ($null -ne $ID) {
        $ScriptSearch = get-childitem -path $folderRange -include ("*$ID.pdf") -erroraction silentlycontinue -recurse -depth 0
        #if ($ScriptSearch = "") {write-output "/n/t/t Packing slip not found."; Return;}
        $rval = ($ScriptSearch | sort-object -Property "LastWriteTime" -descending | Select-Object -f 1).FullName
        if ($v) {
            Write-Host -ForegroundColor Yellow "`$ID: $ID`n`$folderRange: $folderRange`n`$ScriptSearch: $ScriptSearch`n`$rval: $rval"
        }
        If ($open -eq $true) {
            start-process -filepath $rval -verb open
            return
        }
        else {
            $rval
            #exit
        }
    }
    else {
        write-output "`n`tOrderFinder did not get the variable from the parameter; check code!"
    }
}

function SearchForLogoByScript {
    $string = Read-Host -prompt "`nPlease enter the logo script of the desired logo:`n"
    #write-output $string
    $string = LogoScriptWildcarder($string)
    #write-output $string
    $ScriptSearch = get-childitem -path $FolderRange -include ("`*" + ($string) + "`*") -erroraction silentlycontinue -recurse
    #write-output "`$ScriptSearch is $ScriptSearch"
    $rval = ($ScriptSearch | sort-object -Property "LastWriteTime" -descending | Select-Object -f 1).FullName
    if ($v) {
        Write-Host -ForegroundColor Yellow "`$string: $string`n`$ScriptSearch: $ScriptSearch`n`$rval: $rval"
    }
    If ($null -eq $rval) {
        Write-Host -foregroundcolor Red "Logo was not found, try again."
    }
    else {
        explorer "/select,$rval"
    }
}
function ShopLogoByScript($dir) {
    $string = Read-Host -prompt "`nPlease enter the logo script of the desired logo:`n"
    #write-output $string
    $string = LogoScriptWildcarder($string)
    #write-output $string
    $ScriptSearch = get-childitem -path $dir -include (($string) + "*") -erroraction silentlycontinue -recurse
    #write-output "`$ScriptSearch is $ScriptSearch"
    $rval = ($ScriptSearch | sort-object -Property "LastWriteTime" -descending | Select-Object -f 1).FullName
    #write-output "`$rval is $rval"
    If ($null -eq $rval) {
        Write-Host -foregroundcolor Red "Logo was not found, try again."
    }
    else {
        explorer /select,$rval
    }
}

<# function LogoScriptWildcarder($unsearchable) {
    $theReplacers = @("\*\*\*","\*\*","track\*and\*field","track\*&\*field","swim\*and\*dive","swim\*&\*dive")
    $theReplacements = @("*","*","track","track","swim","swim")
    $searchable = $unsearchable -replace "\|", "*"
    $searchable = $searchable -replace " ", "*"
    $searchable = $searchable -replace "\.", "*"
    #$searchable = $searchable -replace "\W","*"
    $searchable = $searchable -replace "\d"
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

} #>

if ($ID -gt $null -And -not $history -And -not $OrderForm -and -not $status) {
    $lookupUrl = "$db_uri/orders/$ID"
    $response = Get-Response $lookupUrl
    Add-LogoUrls $response
    #write-output "`tlogo search based on ID`n`n"
    LogoFinder($response)
}
elseif ($OrderForm -And $ID) {
    $lookupUrl = "$db_uri/orders/$ID"
    $response = Get-Response $lookupUrl
    #write-output "`torder form search`n"
    OrderFinder $ID $true
}
elseif ($SearchForScript) {
    SearchForLogoByScript
}
elseif ($Shop) {
    ShopLogoByScript 'D:\Snap$hop'
}
elseif ($history -and $ID) {
    $lookupUrl = "$db_uri/orders/$ID"
    $response = Get-Response $lookupUrl
    $folderRange = "$shareDrive"
    LogoFinder($ID)
    if ($OrderForm) { OrderFinder $ID $true }
}
elseif ($status -and $ID) {
    chrome "https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$ID&whence="
}
elseif ($share) {
    $folderRange = "G:\My Drive\Logos"
    $logoSearch = Get-childitem -path "$FolderRange" -include ($share + "*") -Recurse
    $logoFile = ($logoSearch | Select-Object -f 1).FullName
    If ($null -eq $logoFile) {
        Write-Output "logo not found!"
    }
    else {
        explorer /select,$logoFile
    }
}
else {
    $ID = Read-Host -prompt "`n`tPlease enter an Order ID to find logos for"
    $check = $ID -match "^\d{5-8}$"
    if ($check -eq $true) {
        LogoFinder $ID

    }
    else {
        write-output "`tincorrect order Id format entered, try again."
    }
}
