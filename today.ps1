$i = 0
$dir = $shareDrive
$roll = @("1","2","3","4")
#uncomment out '-format "MMdd"' to return to old folder date naming scheme
$date = get-date # -Format "MMdd"
$rollFile = 'r{0:MMdd}0' -f $date
$rollder = $rollFile + $roll[$i]
#old Folder naming scheme
#$week = (get-date -format yyMMdd) - (6+(get-date).dayofweek)%7
$week = $date.AddDays([DayOfWeek]::Monday - [int]$date.DayOfWeek)
$week = '{0:yyMMdd}' -f $week
$Types = @("OTF","Rolanda","Reorder", "$user`_DL")
function buildDirectory($i) {
    $layer1 = $dir + "AA" + $week
    if ($layer1) {
        for ($t = 0; $t -lt $Types.length; $t++) {
            $Type = $Types[$t]
            if (!(test-path "$layer1\$Type")) {
                mkdir "$layer1\$Type"
            }
        }
        For ($i = 0; $i -lt 4; $i++) {
            $rollder = $rollFile + $roll[$i]
            $curPath = "$layer1\$rollder"
            if (!(test-path $curPath)) {
                mkdir $curPath
            }
            #Set-Location $curPath
        }
    } else {
        mkdir $layer1
    }
}
buildDirectory($i)
$USER_DOWNLOAD_FOLDER = $Types[3]
set-location "$dir`AA$week\$USER_DOWNLOAD_FOLDER"

#set chrome download location-------------------
#
####    DOES NOT CURRENTLY WORK     ####
#
#ChromeSettingsFile
# $LocalAppData = [Environment]::GetFolderPath( [Environment+SpecialFolder]::LocalApplicationData )
# $ChromeDefaults = Join-Path $LocalAppData "Google\Chrome\User Data\Profile 1"
# $ChromePrefFile = Join-Path $ChromeDefaults "Preferences"
# $Settings = Get-Content $ChromePrefFile | ConvertFrom-Json
# #set location
# $Settings.download.default_directory = "$dir`AA$week\$rollder"
# write-output "Set Chrome downloads to $dir`AA$week\$rollder"
# #save pref file
# $Settings | ConvertTo-Json | Out-File -FilePath $ChromePrefFile -Force