#$api_documentation_uri="https://earthquake.usgs.gov/fdsnws/event/1/" #API documentation 

#paramethers
$min_magnitude=5
$start_time="2024-02-01"
$end_time="2024-04-30"
$min_magnitude_earthquakes_file_path=".\min_magnitude.txt"
$max_magnitude_earthquakes_file_path=".\max_magnitude.txt"
$avg_cdi_file_path=".\avg_cdi.txt"


#transfering API call (JSON format) to list of PS Objects with Invoke-RestMethod 
$api_uri="https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=$start_time&endtime=$end_time&minmagnitude=$min_magnitude" #ISO8601 Date/Time format for date : YYYY-MM-DD
$RestMethod = Invoke-RestMethod -Uri $api_uri -Method Get
#($RestMethod.features).GetType() #Array of PowerShell Objects


$cdi_sum=0
$mag_sum=0
$Earthquakes=New-Object Collections.Generic.List[Object]
foreach($Item in $RestMethod.features){ 

   

    $Earhquake=[PSCustomObject]@{
        mag = $Item.properties.mag
        place = $Item.properties.place
        updated = [datetime]::FromFileTimeUtc($Item.properties.updated).ToString("HH:mm:ss.fff")
    }
    $cdi_sum+=$Item.properties.cdi
    $mag_sum+=$Item.properties.mag
    $Earthquakes.Add($Earhquake)
    
}

#$Earthquakes.GetType() List of Objects

#if(!(Test-Path -Path $min_magnitude_file_path)){
#    New-Item -Path $min_magnitude_file_path -ItemType File
#}

$Earthquakes | Where-Object -FIlter {$_.mag -eq $min_magnitude} > $min_magnitude_earthquakes_file_path

#if(!(Test-Path -Path $max_magnitude_file_path)){
#    New-Item -Path $max_magnitude_file_path -ItemType File
#}

$max = $($Earthquakes | Sort-Object mag -Descending)[0].mag
$Earthquakes | Where-Object -Filter {$_.mag -eq $max} > $max_magnitude_earthquakes_file_path

#if(!(Test-Path -Path $avg_cdi_file_path)){
#    New-Item -Path $avg_cdi_file_path -ItemType File
#}

$avg_cdi = $cdi_sum/$Earthquakes.Count
$avg_mag = $mag_sum/$Earthquakes.Count
"Avreage intensity based on CDI (Community Internet Intensity Map) is " + $avg_cdi +
". Average intensity based on magnitude measurements is "+ $avg_mag | Out-File $avg_cdi_file_path