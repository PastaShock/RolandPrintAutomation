#created by George Pastushok september 16th 2019
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
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("orderID", "i")]
        #[ValidateRange(9999,999999)]
        #[ValidatePattern("^\d{6}$")]
        [String[]] $ID,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("OF", "o", "PackingSlip")]
        #[ValidatePattern("^\d{5}$")]
        [switch] $OrderForm,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [Alias("logo", "script", "text", "l", "s")]
        [switch] $SearchForScript,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [Alias("snapshop")]
        [switch] $Shop,
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [Alias("Archive", "h", "a")]
        [switch] $history,
        #get order id and get /process on order
        [Parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [switch] $status,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("google", "g")]
        [string] $share
        
    )

. "$scriptsHome\lib.ps1"


$FolderRange = ($shareDrive+"AA*")


function LogoFinder($criteria) {
    #placeholder If conditional
    if ($null -ne $criteria) {
        #find all ordersIds that match search criteria
        $PackingSlip = OrderFinder $criteria $false
                if ($null -ne $PackingSlip) {
                    $ORDER = $REPRINTS.$criteria | Select-Object -f 1
                    $script = $ORDER.logoScript
                    $fund_id = $ORDER.fundid
                    $placedOn = $Order.placedDate
                    $color = "DarkRed"
                    $conColor = "Yellow"
                    write-host "`tOrder ID:`t" -nonewline
                    write-host -foregroundcolor $color "$criteria`t`t" -nonewline
                    write-host "Fund ID: " -nonewline
                    write-host -foregroundcolor $color "$fund_id"
                    write-host "`tLogo Script:`t" -nonewline
                    write-host -foregroundcolor $color "$script"
                    write-host "`tPlaced On:`t" -nonewline
                    write-host -foregroundcolor $color "$placedOn"
                    write-host "`tOccurences: " -NoNewline
                    write-host ""
                    #$searchScript = LogoScriptWildcarder $script
                    $refind = (get-item $PackingSlip).Directory.FullName
                    #$logoSearch = Get-childitem -path "$refind" -include ("*" + $searchScript) -ErrorAction SilentlyContinue -depth 0
                    $logoSearch = Get-childitem -path "$refind" -include ("*" + $fund_id + "*") -Recurse
                    #trim line endings and leading and or trailing zeroes.
                    write-host -foregroundcolor $conColor "`tOrder "$criteria" is located at: "($refind.trim("\`n"))""
                    $logoFile = $logoSearch | Select-Object -f 1
                    If ($null -eq $logoFile) {
                        set-clipboard -value $refind
                        explorer $refind
                        } else {
                        explorer /select,$logoFile
                        }
                    } else {
                    write-host "`tsearch for $criteria returned nothing"
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
        }
    }

function OrderFinder($ID, $open) {
    If ($null -ne $ID) {
        $ScriptSearch = get-childitem -path $folderRange -include ("*$ID.pdf") -erroraction silentlycontinue -recurse -depth 0
        #if ($ScriptSearch = "") {write-output "/n/t/t Packing slip not found."; Return;}
        $rval = ($ScriptSearch | sort-object -Property "LastWriteTime" -descending | Select-Object -f 1).FullName
        If ($open -eq $true) {
            start-process -filepath $rval -verb open
            return
        } else {
            $rval
            #exit
        }
    } else {
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
    #write-output "`$rval is $rval"
    If ($null -eq $rval) {
        Write-Host "Logo was not found, try again."
    } else {
        explorer.exe /select,$rval
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
            Write-Host "Logo was not found, try again."
        } else {
            explorer.exe /select,$rval
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
            #write-output "`tlogo search based on ID`n`n"
            LogoFinder($ID)
    }
    elseif ($OrderForm -And $ID) {
            #write-output "`torder form search`n"
        OrderFinder $ID $true
    }
    elseif($SearchForScript) {
        SearchForLogoByScript
    }
    elseif($Shop) {
        ShopLogoByScript 'D:\Snap$hop'
    }
    elseif($history -and $ID) {
        $folderRange = "$shareDrive"
        LogoFinder($ID)
        if ($OrderForm) {OrderFinder $ID $true}
    }
    elseif($status -and $ID) {
        chrome "https://4766534.app.netsuite.com/app/accounting/transactions/salesord.nl?id=$ID&whence="
    }
    elseif($share) {
        $folderRange = "G:\My Drive\Logos"
        $logoSearch = Get-childitem -path "$FolderRange" -include ($share + "*") -Recurse
        $logoFile = ($logoSearch | Select-Object -f 1).FullName
                    If ($null -eq $logoFile) {
                        Write-Output "logo not found!"
                        } else {
                        explorer /select,$logoFile
                        }
    }
    else {
        $ID = Read-Host -prompt "`n`tPlease enter an Order ID to find logos for"
        $check = $ID -match "^\d{5}$"
        if ($check -eq $true) {
            LogoFinder $ID

        }
        else {
            write-output "`tincorrect order Id format entered, try again."
        }
    }