param([int]$PortOffset=0)
$ErrorActionPreference='Stop'
$gateway="http://localhost:$((8080+$PortOffset))"
$services=@(@('forests','forest-biodiversity-service'),@('fire-risk','fire-risk-service'),@('incidents','incident-service'),@('recovery','recovery-service'),@('volunteers','volunteer-service'),@('resources','resource-service'),@('analytics','analytics-service'))
$results=foreach($service in $services){
 $passed=$false;$details='Not ready'
 for($attempt=0;$attempt -lt 60;$attempt++){
  try{
   $identity=Invoke-RestMethod "$gateway/$($service[0])/hello" -TimeoutSec 3
   $docPath=if($service[0] -eq 'analytics'){'openapi.json'}else{'v3/api-docs'}
   $document=Invoke-RestMethod "$gateway/$($service[0])/$docPath" -TimeoutSec 3
   $server=$document.servers[0].url
   $passed=$identity.service -eq $service[1] -and $identity.status -eq 'UP' -and $null -ne $document.paths.'/hello'.get -and ($server -eq "$gateway/$($service[0])" -or $server -eq "/$($service[0])")
   if($passed){$details="Port $($identity.port); OpenAPI + gateway server verified";break}
  }catch{$details=$_.Exception.Message}
  Start-Sleep -Seconds 1
 }
 [pscustomobject]@{Service=$service[1];Status=$(if($passed){'PASS'}else{'FAIL'});Details=$details}
}
$config=Invoke-RestMethod "$gateway/v3/api-docs/swagger-config"
$results|Format-Table -AutoSize
if(@($results|Where-Object Status -eq 'FAIL').Count -or @($config.urls).Count -ne 7){exit 1}
Write-Output 'All seven routed APIs, OpenAPI descriptions, and Swagger choices passed.'
