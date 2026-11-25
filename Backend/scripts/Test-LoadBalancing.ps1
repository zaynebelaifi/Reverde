param([int]$PortOffset=0)
$ErrorActionPreference='Stop'
$directory=Join-Path (Split-Path $PSScriptRoot -Parent) 'incident-service'
$port=8183+$PortOffset
$gateway="http://localhost:$((8080+$PortOffset))"
$registry="http://localhost:$((8761+$PortOffset))/eureka/"
if(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue){throw "Replica port $port is occupied."}
if(!$env:JAVA_HOME){throw 'Set JAVA_HOME to JDK 17+.'}
$classpath=(Join-Path $directory 'target/classes')+';'+(Get-Content -Raw "$directory/target/integration-classpath.txt").Trim()
$replica=Start-Process -FilePath "$env:JAVA_HOME/bin/java.exe" -ArgumentList @('-Xmx192m','-classpath',('"'+$classpath+'"'),'com.reverde.incident.IncidentApplication',"--server.port=$port","--eureka.client.service-url.defaultZone=$registry") -WorkingDirectory $directory -WindowStyle Hidden -RedirectStandardOutput "$directory/target/replica-test.log" -RedirectStandardError "$directory/target/replica-test-error.log" -PassThru
try{
 $ports=@()
 for($attempt=0;$attempt -lt 90;$attempt++){
  try{
   $ports=@(1..8|ForEach-Object{(Invoke-RestMethod "$gateway/incidents/hello" -TimeoutSec 3).port})
   if(($ports|Select-Object -Unique).Count -ge 2 -and $ports -contains $port){break}
  }catch{}
  Start-Sleep -Seconds 1
 }
 if(($ports|Select-Object -Unique).Count -lt 2 -or $ports -notcontains $port){throw 'Two-instance discovery/load balancing was not observed.'}
 $ports|Group-Object|Select-Object @{Name='InstancePort';Expression={$_.Name}},Count|Format-Table -AutoSize
 Write-Output 'PASS: requests reached both real Eureka-registered incident instances.'
}finally{
 # Windows Stop-Process is abrupt; explicitly remove our replica lease first.
 $instanceId=[Uri]::EscapeDataString("localhost:incident-service:$port")
 try{Invoke-WebRequest -Method Delete -Uri "${registry}apps/INCIDENT-SERVICE/$instanceId" -TimeoutSec 3|Out-Null}catch{Write-Warning 'Replica deregistration failed; its Eureka lease may remain temporarily.'}
 $current=Get-CimInstance Win32_Process -Filter "ProcessId=$($replica.Id)"
 if($current -and $current.CommandLine -match 'com.reverde.incident.IncidentApplication'){
  Stop-Process -Id $replica.Id
 }
}
