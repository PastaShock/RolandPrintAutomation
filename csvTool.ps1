# Fill empty date cells with todays date
# Clean up rows with edits in them and parenthesis

$csv = Import-CSV .\reprints.csv;

Function csvfill {
	param (
		$subCatDesc
	)
	foreach ($row in $csv[1..($csv.length-1)]) {
    	if (!$row.$subCatDesc) {
			$row.$subCatDesc = $prevRow.$subCatDesc;
		}
			$prevRow = $row;
	}
}

foreach ($row in $csv) {
	if (!$row.date) {
		$row.date = (Get-Date -Format "MM/dd/yyyy");
	#} else {
		#csvFill -subCatDesc date
	}
	if ($row.error -match "\([A-z0-9 ]+\)") {
		$row.error = ($row.error | Select-String "\(([A-z0-9 ]+)\)" | Select-object -expand matches | select-object -expand groups | select-object -expand value)[1];
	}
	if ($row.error -eq "edited") {
		$row.error = "";
	}
}

# Fill cells with previous row's data to complete every row
csvFill -subCatDesc time
csvFill -subCatDesc name
csvFill -subCatDesc orderId

# Export the edited table as a csv
$csv | export-csv -Path .\reprints.csv -NoTypeInformation;

# re-import the csv to print it into the console to verify data
#$csv = Import-CSV .\reprints.csv;
$csv | Format-Table;
