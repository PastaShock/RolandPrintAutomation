# Fill empty date cells with todays date
Function csvfill {
	param (
		$subCatDesc
	)
	$csv = import-csv .\reprints.csv;
	$prevRow = $csv[0]; 
	foreach ($row in $csv[1..($csv.length-1)]) {
    	if (!$row.$subCatDesc) {
			$row.$subCatDesc = $prevRow.$subCatDesc };
			$prevRow = $row;
			$csv | export-csv -Path .\reprints.csv -NoTypeInformation;
	}
}

# Clean up rows with edits in them
$csv = Import-CSV .\reprints.csv;
foreach ($row in $csv) {
	if ($row.error -match "\([A-z0-9 ]+\)") {
		$row.error = ($row.error | Select-String "\(([A-z0-9 ]+)\)" | Select-object -expand matches | select-object -expand groups | select-object -expand value)[1];
	}
	if ($row.error -eq "edited") {
		$row.error = "";
	}
	$csv | export-csv -Path .\reprints.csv -NoTypeInformation;
}

#wrap all the smaller functions into one command
Function csvComplete {
	$csv = import-csv -Path .\reprints.csv;
	$csv | forEach-Object{
		$_.date = (Get-Date -Format "MM/dd/yyyy");
	#return $_;
	}
	$csv | export-csv -Path .\reprints.csv -NoTypeInformation;
	csvFill -subCatDesc time
	csvFill -subCatDesc name
	csvFill -subCatDesc orderId
}

csvComplete

$csv = Import-CSV .\reprints.csv;

$csv | Format-Table;
