param([string]$Gateway='http://localhost:8080')
$ErrorActionPreference='Stop'
$destination=Join-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) 'documentation/openapi'
New-Item -ItemType Directory -Path $destination -Force | Out-Null
$routes=@('forests','fire-risk','incidents','recovery','volunteers','resources','analytics')
foreach($prefix in $routes){
 $path=if($prefix -eq 'analytics'){'openapi.json'}else{'v3/api-docs'}
 $document=Invoke-RestMethod "$($Gateway.TrimEnd('/'))/$prefix/$path"
 $document.servers=@(@{url="/$prefix";description='Public gateway route'})
 $document|ConvertTo-Json -Depth 60|Set-Content (Join-Path $destination "$prefix.json") -Encoding UTF8
 Write-Output "Exported $prefix"
}
