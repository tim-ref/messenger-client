echo $args[0]

$PARAMS = $args[0] -replace '.*tim://' -replace ".$"

Start-Process "https://tim-client.eu.timref.akquinet.nx2.dev/#/hba?$PARAMS"

