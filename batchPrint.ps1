[cmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Alias("printer", "p")]
        [ValidateRange(0,4)]
        [int] $desiredPrinter,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("type", "t")]
        [switch] $orderType,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [Alias("r")]
        [switch] $roll,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
        [switch] $verbosity

    )
if ($orderType -ne $true -and $roll -ne $true) {
    #write-output "Case0"
    if ($verbosity) {
        Write-Output -foregroundcolor Yellow "batchPrint:ln21:debugmode`n`torderType: $orderType`n`troll: $roll`n`tdesiredPrinter: $desiredPrinter`n`torderType: $orderType"
    }
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 1 $verbosity}
} elseif ($roll -ne $true -and $orderType -eq $true) {
    #write-output "Case1"
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 1 -orderType $verbosity}
} elseif ($roll -eq $true -and $orderType -ne $true) {
    #write-output "Case2"
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 3 $verbosity}
} 
if (!($verbosity)) {
    notepad $log
    Move-Item 'orders.json' .. -Force
}
exit
