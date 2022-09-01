#This script will take a list of order IDs from a file, find their matching logo script
#or other information and send it to the node app that prints the label.

#convert the database to a variable
#perhaps update this to a lookup of the passed(below, in the for-each loop) order id
#$orderPrintHistory = ($shareDrive+"temp\ORDERS_DATABASE.JSON")
$orders = Get-Content $DATABASE | ConvertFrom-Json

Get-Content $labels | foreach-object $_ {
    $orderinfo = $orders.$_ | select-object -f 1
    $script = $orderInfo.logoscript
    $orderid = $orderInfo.orderID
    $salesOrder = $orderInfo.salesOrder
    $magentoId = $orderInfo.magentoId
    $fundId = $orderInfo.fundId
    node C:\ps\label_temp\app.js --script=$script --orderid=$orderid --salesOrder=$salesOrder --fundraiserId=$fundId --magentoId=$magentoId
};

exit