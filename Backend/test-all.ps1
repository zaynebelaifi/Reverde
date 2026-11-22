$services=@(@{Name='forest-biodiversity-service';Port=8081},@{Name='fire-risk-service';Port=8082},@{Name='incident-service';Port=8083},@{Name='recovery-service';Port=8084},@{Name='volunteer-service';Port=8085},@{Name='resource-service';Port=8086},@{Name='analytics-service';Port=8090})
$results=foreach($s in $services){$ready=$false;$x=$null;for($attempt=0;$attempt -lt 60 -and -not $ready;$attempt++){try{$x=Invoke-RestMethod "http://localhost:$($s.Port)/hello" -TimeoutSec 2;$ready=$x.service -eq $s.Name -and $x.status -eq 'UP' -and [int]$x.port -eq $s.Port}catch{};if(-not $ready){Start-Sleep 1}};if($ready){[pscustomobject]@{Service=$s.Name;Port=$s.Port;Status='PASS';Details=($x|ConvertTo-Json -Compress)}}else{[pscustomobject]@{Service=$s.Name;Port=$s.Port;Status='FAIL';Details='Service unavailable or returned an unexpected response'}}}
$eurekaReady=$false
$eurekaDetails='Eureka server unavailable'
for($attempt=0;$attempt -lt 60 -and -not $eurekaReady;$attempt++){
    try{
        $health=Invoke-RestMethod 'http://localhost:8761/actuator/health' -TimeoutSec 2
        $eurekaReady=$health.status -eq 'UP'
        if($eurekaReady){$eurekaDetails='UP'}
    }catch{}
    if(-not $eurekaReady){Start-Sleep 1}
}
$forestRegistered=$false
$forestRegistrationDetails='Forest biodiversity service is not registered'
if($eurekaReady){
    try{
        $app=Invoke-RestMethod 'http://localhost:8761/eureka/apps/FOREST-BIODIVERSITY-SERVICE' -Headers @{Accept='application/json'} -TimeoutSec 5
        $forestRegistered=$app.application.name -eq 'FOREST-BIODIVERSITY-SERVICE'
        if($forestRegistered){$forestRegistrationDetails='REGISTERED'}
    }catch{}
}
$infrastructure=@(
    [pscustomobject]@{Service='eureka-server';Port=8761;Status=$(if($eurekaReady){'PASS'}else{'FAIL'});Details=$eurekaDetails},
    [pscustomobject]@{Service='forest-eureka-registration';Port=8761;Status=$(if($forestRegistered){'PASS'}else{'FAIL'});Details=$forestRegistrationDetails}
)
@($results)+@($infrastructure)|Format-Table -AutoSize
if(@(@($results)+@($infrastructure)|Where-Object{$_.Status -eq 'FAIL'}).Count -gt 0){exit 1}
