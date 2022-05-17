# $a = get-childitem -include '*-*-*-*.eps' -r

# for ($i = 0; $i -lt $a.count; $i++) {
#     $newName = $a[$i].name.substring(0, $a[$i].BaseName.length-37) + '.eps'
#     if (Test-Path $newName) {
#         Write-Output "`t deleting file $a[$i].name"
#         Remove-Item $a[$i].name
#     } else {
#         Write-Output "`t renaming file: $newName"
#         $a[$i] | rename-item -newname {$newName}
#     }
# }

# define function to take a filename and rename it/trim off excess text
function renameRegex($filename) {
    return $filename.name -replace "^(?:[A-z_0-9-]+)(\d{6}_[ds]+)( \(\d{1,2}\))?", '$1'
}

$c = Get-ChildItem | Where-Object {$_.Name -match "\(*\).eps"}
for ($i = 0; $i -lt $c.count; $i++) {
    $oldName = $c[$i] -split " "
    $newName = $oldName[0] + ".eps"
    $destination = "$pwd\$newName"
    Move-Item $c[$i].Name -Destination $destination -Force
}

# the matching regex should look for 
# ^[order_design_\d{5}-]+(\d{5}_[ds]+)( \(\d{1,2}\))?.eps
$b = Get-ChildItem | Where-Object {$_.Name -match "order_design_\d{4,5}-*"}
for ($i = 0; $i -lt $b.count; $i++) {
    # $oldName = ($b[$i] -split "-")
    for ($j = 1; $j -lt $oldName.count; $j++) {
        $newName = renameRegex($b[$i]);
        # $newName += $oldName[$j];
    }
    #pattern = order_design_{4-6 digits}-{fundId}_{logoSize}_{logoScript}
    if ($newName -eq "") {return}
    if (Test-Path $newName) {
        Write-Output "`t deleting file $newName`n"
        Remove-Item $newName
    } else {
        Write-Output "`t renaming file: $newName`n"
        $b[$i] | rename-item -newname {$newName}
    }
}
Remove-Item "*(*).pdf"
Remove-Item "*(*).json"
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_20" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_7C" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "26" , ""}
#get-childitem -include '*.eps' -r | rename-item -newname {$_.Name -replace "_" , ""}

