$services=@(@{Name='forest-biodiversity-service';Port=8081},@{Name='fire-risk-service';Port=8082},@{Name='incident-service';Port=8083},@{Name='recovery-service';Port=8084},@{Name='volunteer-service';Port=8085},@{Name='resource-service';Port=8086},@{Name='analytics-service';Port=8090})
$results=foreach($s in $services){try{$x=Invoke-RestMethod "http://localhost:$($s.Port)/hello" -TimeoutSec 10;$ok=$x.service -eq $s.Name -and $x.status -eq 'UP' -and [int]$x.port -eq $s.Port;[pscustomobject]@{Service=$s.Name;Port=$s.Port;Status=if($ok){'PASS'}else{'FAIL'};Details=($x|ConvertTo-Json -Compress)}}catch{[pscustomobject]@{Service=$s.Name;Port=$s.Port;Status='FAIL';Details=$_.Exception.Message}}}
$results|Format-Table -AutoSize
if(@($results|where Status -eq FAIL).Count){exit 1}
