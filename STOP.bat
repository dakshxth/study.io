@echo off
setlocal
set "APP_ROOT=%~dp0"
set "PORT_FILE=%APP_ROOT%backend\data\run-ports.txt"
if not exist "%PORT_FILE%" (
  echo No local study app port record was found. It may already be stopped.
  pause
  exit /b 0
)
set "STUDY_APP_PORT_FILE=%PORT_FILE%"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$portValues=(Get-Content -LiteralPath $env:STUDY_APP_PORT_FILE -TotalCount 1).Split(','); foreach($port in $portValues){ $connections=Get-NetTCPConnection -State Listen -LocalPort ([int]$port) -ErrorAction SilentlyContinue; foreach($connection in $connections){ $process=Get-CimInstance Win32_Process -Filter ('ProcessId = '+$connection.OwningProcess) -ErrorAction SilentlyContinue; if($process -and ($process.CommandLine -like '*run_local.py*' -or $process.CommandLine -like '*uvicorn main:app*' -or $process.CommandLine -like '*vite*')){ Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue; Write-Host ('Stopped this local app process '+$process.ProcessId+' on port '+$port) } } }; Remove-Item -LiteralPath $env:STUDY_APP_PORT_FILE -Force -ErrorAction SilentlyContinue"
echo.
echo The local study app has been stopped. Academic data and uploaded files are unchanged.
pause
endlocal
