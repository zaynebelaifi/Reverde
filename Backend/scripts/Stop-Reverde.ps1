param([int]$PortOffset=0)
$ErrorActionPreference='Stop'
$backend=Split-Path $PSScriptRoot -Parent
$manifest=Join-Path $backend ".runtime/stack-$PortOffset/processes.json"
if(!(Test-Path $manifest)){Write-Output 'No managed stack recorded. Stop IDE instances in the IDE.';exit 0}
$remaining=@()
foreach($entry in @(Get-Content -Raw $manifest|ConvertFrom-Json)){
 $process=Get-Process -Id $entry.Id -ErrorAction SilentlyContinue
 if(!$process){continue}
 $details=Get-CimInstance Win32_Process -Filter "ProcessId=$($entry.Id)"
 $recordedStart=[DateTime]$entry.Started
 $sameStart=[Math]::Abs(($process.StartTime.ToUniversalTime()-$recordedStart.ToUniversalTime()).TotalSeconds) -lt 2
 $sameWorkspace=$details.CommandLine -like "*$backend*" -or ($entry.Name -eq 'analytics-service' -and $details.ExecutablePath -like "$backend*")
 if($sameStart -and $sameWorkspace){
  # Windows venv python.exe may launch a child interpreter for Uvicorn.
  if($entry.Name -eq 'analytics-service'){
   foreach($child in @(Get-CimInstance Win32_Process -Filter "ParentProcessId=$($entry.Id)")){
    if($child.CommandLine -match 'uvicorn main:app'){Stop-Process -Id $child.ProcessId -ErrorAction SilentlyContinue}
   }
  }
  Stop-Process -Id $entry.Id -ErrorAction SilentlyContinue
  Write-Output "Stopped $($entry.Name) PID $($entry.Id)"
 }
 else{Write-Warning "PID $($entry.Id) no longer matches. Left running.";$remaining+=$entry}
}
if($remaining.Count){$remaining|ConvertTo-Json -Depth 3|Set-Content $manifest}
else{Remove-Item -LiteralPath $manifest}
