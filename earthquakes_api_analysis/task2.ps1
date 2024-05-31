#$api_documentation_uri="https://earthquake.usgs.gov/fdsnws/event/1/" #API documentation 

#paramethers
$min_magnitude=7
$start_time="2019-01-01"
$end_time="2023-12-31"
$dangerous_earthquakes_with_tsunamis_filepath="./dangerous_earthquakes_with_tsunamis.txt"
$api_uri="https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=$start_time&endtime=$end_time&minmagnitude=$min_magnitude"


$RestMethod = Invoke-RestMethod -Uri $api_uri -Method Get

$dangerous_earthquakes_with_tsunamis=New-Object Collections.Generic.List[Object]

foreach( $Item in $RestMethod.features){
    if($Item.properties.tsunami -eq 1 && $Item.properties.status -eq "red"){
        $Earhquake =[PSCustomObject]@{
            mag = $Item.properties.mag
            place=$Item.properties.place
            updated=[datetime]::FromFileTimeUtc($Item.properties.updated).toString("HH:mm:ss.fff") 
        }
       
        $dangerous_earthquakes_with_tsunamis.Add($Earhquake)
    }
}

$dangerous_earthquakes_with_tsunamis | Out-File $dangerous_earthquakes_with_tsunamis_filepath