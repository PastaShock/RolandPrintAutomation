# George Pastushok 2023
# Print a label to the console
# Get the order's information and pass it through into a templated string

$order = $orders.16096808

$topText = $order.logoScript + "-" + $order.fundId
$BottomText = $order.orderId + "-" + $order.salesOrder

$ts = "_"*( ( 40 - $topText.length) / 2 )
$bs = "_"*( ( 40 - $BottomText.length) / 2 )

$consoleLabel=@"
╔========================================╗
║$ts$topText$ts║
║$bs$BottomText$bs║
╚========================================╝
"@

$consoleLabel