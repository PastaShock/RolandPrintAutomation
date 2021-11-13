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
        [switch] $roll

    )
if ($orderType -ne $true -and $roll -ne $true) {
    #write-output "Case0"
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 1}
} elseif ($roll -ne $true -and $orderType -eq $true) {
    #write-output "Case1"
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 1 -orderType}
} elseif ($roll -eq $true -and $orderType -ne $true) {
    #write-output "Case2"
    get-content -path "$printlist" | foreach-object {incentive -i $_ -p $desiredPrinter -q 3}
} 
notepad $log
Move-Item 'orders.json' .. -Force
exit
