#This script will take a list of order IDs from a file, find their matching logo script
#or other information and send it to the node app that prints the label.


Get-Content $labels | foreach-object $_ {
    $orderinfo = (Invoke-WebRequest -Method GET -Uri "$db_uri/orders/$_").Content | ConvertFrom-Json
    # $orderinfo = $orders.$_ | select-object -f 1
    $script = $orderInfo.logo_script
    $orderid = $orderInfo.order_id
    . $scriptsHome/consoleLabel.ps1 -ID $orderid
    $salesOrder = $orderInfo.sales_order_id
    $magentoId = $orderInfo.magento_id
    $fundId = $orderInfo.fundraiser_id
    node C:\ps\label_temp\app.js --script=$script --orderid=$orderid --salesOrder=$salesOrder --fundraiserId=$fundId --magentoId=$magentoId
};

exit