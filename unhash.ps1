$a = get-childitem -include '*-*-*-*.eps' -r

for ($i = 0; $i -lt $a.count; $i++) {
    $newName = $a[$i].name.substring(0, $a[$i].BaseName.length-37) + '.eps'
    if (Test-Path $newName) {
        Write-Output "`t deleting file $a[$i].name"
        Remove-Item $a[$i].name
    } else {
        Write-Output "`t renaming file: $newName"
        $a[$i] | rename-item -newname {$newName}
    }
}

$b = Get-ChildItem -include "order_design_*" -Recurse
for ($i = 0; $i -lt $b.count; $i++) {
    $newName = $b[$i].name.substring(18)
    if (Test-Path $newName) {
        Write-Output "`t deleting file $b[$i].name"
        Remove-Item $b[$i].name
    } else {
        Write-Output "`t renaming file: $newName"
        $b[$i] | rename-item -newname {$newName}
    }
}

Remove-Item "*(*).*"
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_20" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_7C" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "26" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_" , ""}

