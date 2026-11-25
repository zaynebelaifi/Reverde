param([int]$PortOffset=0, [switch]$SkipBuild, [switch]$InstallPython)
$ErrorActionPreference='Stop'
$backend=Split-Path $PSScriptRoot -Parent
$runtime=Join-Path $backend ".runtime/stack-$PortOffset"
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$manifest=Join-Path $runtime 'processes.json'
if(Test-Path $manifest){throw "Managed stack exists. Run Stop-Reverde.ps1 -PortOffset $PortOffset first."}
if(!$env:JAVA_HOME -or !(Test-Path "$env:JAVA_HOME/bin/java.exe")){throw 'Set JAVA_HOME to JDK 17 or newer.'}
$definitions=@(
 @('eureka-server',8761,'com.reverde.eureka.EurekaServerApplication'),
 @('forest-biodiversity-service',8081,'com.reverde.forestbiodiversity.ForestBiodiversityApplication'),
 @('fire-risk-service',8082,'com.reverde.firerisk.FireRiskApplication'),
 @('incident-service',8083,'com.reverde.incident.IncidentApplication'),
 @('recovery-service',8084,'com.reverde.recovery.RecoveryApplication'),
 @('volunteer-service',8085,'com.reverde.volunteer.VolunteerApplication'),
 @('resource-service',8086,'com.reverde.resource.ResourceApplication'),
 @('api-gateway',8080,'com.reverde.gateway.ApiGatewayApplication')
)
foreach($definition in $definitions + ,@('analytics-service',8090,'')){
 $port=[int]$definition[1]+$PortOffset
 if(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue){throw "Port $port is occupied. Stop its existing instance in the owning application first."}
}
$python=Join-Path $backend 'analytics-service/.venv/Scripts/python.exe'
if($InstallPython){
 if(!(Test-Path $python)){& python -m venv (Join-Path $backend 'analytics-service/.venv');if($LASTEXITCODE){throw 'Python environment creation failed.'}}
 & $python -m pip install -r (Join-Path $backend 'analytics-service/requirements.txt')
 if($LASTEXITCODE){throw 'Python installation failed.'}
}
if(!(Test-Path $python)){throw 'Initialize Python with -InstallPython.'}
if(!$SkipBuild){foreach($definition in $definitions){
 $directory=Join-Path $backend $definition[0]
 & "$directory/mvnw.cmd" -B -f "$directory/pom.xml" compile dependency:build-classpath '-DincludeScope=runtime' '-Dmdep.outputFile=target/integration-classpath.txt' *> (Join-Path $runtime "$($definition[0])-build.log")
 if($LASTEXITCODE){throw "Build failed: $($definition[0]). See $runtime."}
}}
$started=@()
$eurekaUrl="http://localhost:$((8761+$PortOffset))/eureka/"
try{
 foreach($definition in $definitions){
  $name=$definition[0];$directory=Join-Path $backend $name;$port=[int]$definition[1]+$PortOffset
  $classpath=(Join-Path $directory 'target/classes')+';'+(Get-Content -Raw "$directory/target/integration-classpath.txt").Trim()
  $javaArgs=@('-Xmx256m','-classpath',('"'+$classpath+'"'),$definition[2],"--server.port=$port","--eureka.client.service-url.defaultZone=$eurekaUrl")
  $process=Start-Process -FilePath "$env:JAVA_HOME/bin/java.exe" -ArgumentList $javaArgs -WorkingDirectory $directory -WindowStyle Hidden -RedirectStandardOutput (Join-Path $runtime "$name.log") -RedirectStandardError (Join-Path $runtime "$name-error.log") -PassThru
  $started+=@{Name=$name;Id=$process.Id;Started=$process.StartTime.ToUniversalTime().ToString('o');Port=$port}
  $started|ConvertTo-Json -Depth 3|Set-Content $manifest
  if($name -eq 'eureka-server'){
   $ready=$false
   for($attempt=0;$attempt -lt 90;$attempt++){
    try{$health=Invoke-RestMethod "http://localhost:$port/actuator/health" -TimeoutSec 2;if($health.status -eq 'UP'){$ready=$true;break}}catch{}
    Start-Sleep -Seconds 1
   }
   if(!$ready){throw 'Eureka did not become ready. Check runtime logs.'}
  }
  Write-Output "Started $name on $port (PID $($process.Id))"
 }
 $oldEureka=$env:EUREKA_URL;$oldPort=$env:SERVER_PORT
 try{
  $env:EUREKA_URL=$eurekaUrl;$env:SERVER_PORT=[string](8090+$PortOffset)
  $process=Start-Process -FilePath $python -ArgumentList @('-m','uvicorn','main:app','--host','0.0.0.0','--port',$env:SERVER_PORT) -WorkingDirectory (Join-Path $backend 'analytics-service') -WindowStyle Hidden -RedirectStandardOutput (Join-Path $runtime 'analytics-service.log') -RedirectStandardError (Join-Path $runtime 'analytics-service-error.log') -PassThru
  $started+=@{Name='analytics-service';Id=$process.Id;Started=$process.StartTime.ToUniversalTime().ToString('o');Port=(8090+$PortOffset)}
  $started|ConvertTo-Json -Depth 3|Set-Content $manifest
 }finally{$env:EUREKA_URL=$oldEureka;$env:SERVER_PORT=$oldPort}
 Write-Output "Stack started. Swagger: http://localhost:$((8080+$PortOffset))/swagger-ui.html"
 Write-Output "Logs and process IDs: $runtime"
 Write-Output 'Run Test-Reverde.ps1 to wait for discovery and verify every route.'
}catch{
 & "$PSScriptRoot/Stop-Reverde.ps1" -PortOffset $PortOffset
 throw
}
