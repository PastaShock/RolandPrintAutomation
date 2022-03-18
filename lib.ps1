function LogoScriptWildcarder($unsearchable){
    if ($unsearchable.split("{|}").length -eq 3) {
        $split = $unsearchable.split("{|}")
        $unsearchable = $split[0] + "*" + $split[2]
    }
    $theReplacers = @("\*\*\*","\*\*","track\*and\*field","track\*&\*field","swim\*and\*dive","swim\*&\*dive","swimming","volleyball","basketball")
    $theReplacements = @("*","*","track","track","swim","swim","swim","volley","b*ball")
    $searchable = $unsearchable -replace "\|", "*"      #replace pipe
    $searchable = $searchable -replace " ", "*"         #replace whitespace
    $searchable = $searchable -replace "\.", "*"        #replace periods
    #$searchable = $searchable -replace "\W","*"        #replace non-word characters
    #$searchable = $searchable -replace "\d"             #replace digits
    for ($i = 0; $i -lt $theReplacers.length; $i++) {
        if ($searchable -match $theReplacers[$i]) {
            $searchable = $searchable -replace $theReplacers[$i],$theReplacements[$i]
        }
    }
    if ($searchable -match "\*$") {
        return $searchable
    } else {
        $searchable + '*'
    }
}