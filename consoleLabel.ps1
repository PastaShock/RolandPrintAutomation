# George Pastushok 2024
# updated to use new database api
# Print a label to the console
# Get the order's information and pass it through into a templated string
[CmdletBinding()]
param (
    # Parameter help description
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Int] $ID
)

# $order = $orders.16096808
$order = (Invoke-RestMethod -Method GET -Uri "$db_uri/orders/$ID")

# Set the top text and the bottom text of the label
if ($order.logo_script) {
    $firstItem = $order.logo_script
} else {
    $firstItem = $order.magento_id
}
$topText = "$($firstItem) - $($order.fundraiser_id)"
$BottomText = "$($order.order_id) - $($order.sales_order_id)"

# Set the spacings of each line
# label total character width = 40
# of the available character width, take away the length of the line to get remaining space
# divide the remaining space by two to get the space length on either side of the line
# $spacing = (widthOfLabel - lengthOfLine)
# spacing = spacing / 2
# if spacing % 2 = 1
# 
$labelLength = 35
# create an array of " " with length of spacing
$lines = @($topText, $BottomText)
# $lines.Length
$edge = "="*$labelLength
Write-Output "╔$edge╗"
for ($i = 0; $i -lt $lines.Length; $i++) {
    $spacing = [Math]::Round($labelLength - $lines[$i].length)
    $adjust = " "*([Math]::Round($spacing % 2) + [Math]::Round($spacing / 2))
    $spacing = $spacing / 2
    $pad = " "*$spacing
    $line = $pad + $lines[$i] + $adjust
    Write-Output "║$line║"
}
Write-Output "╚$edge╝"