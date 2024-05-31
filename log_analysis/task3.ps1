#log file analysis
$log_path=".\SSH_2k.log"
$failed_logs_path=".\failed_logs.txt"
$failed_log_statistics_path=".\failed_log_statistics.txt"

Get-Content $log_path | Select-String "Failed password for" | Out-File $failed_logs_path

$res=Get-Content $failed_logs_path | Select-String -Pattern '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' -AllMatches

#$res.Matches is an array of objects with properties

$stats = $res.Matches | Group-Object -Property Value 

foreach($item in $stats){
 "IP address "+$item.Name+" failed to log to this server "+$item.Count+" times." >> $failed_log_statistics_path 
}