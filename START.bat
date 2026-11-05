@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "APP_ROOT=%~dp0"
set "BACKEND_DIR=%APP_ROOT%backend"
set "FRONTEND_DIR=%APP_ROOT%frontend"
set "PYTHON=%APP_ROOT%.venv\Scripts\python.exe"
set "APP_URL=http://127.0.0.1:5173/"

echo.
echo  ==========================================================
echo   PRIVATE ENGINEERING STUDY PLATFORM
echo   Local browser app - not published or publicly hosted
echo  ==========================================================
echo.

if not exist "%PYTHON%" (
  echo [ERROR] Local Python environment was not found:
  echo         %PYTHON%
  echo.
  echo Install Python 3.11 or newer, then create the project environment:
  echo   py -3 -m venv .venv
  echo   .venv\Scripts\python.exe -m pip install -r backend\requirements.txt
  echo   .venv\Scripts\python.exe -m pip install pytest httpx
  echo.
  pause
  exit /b 1
)

if not exist "%FRONTEND_DIR%\node_modules\vite\bin\vite.js" (
  echo [ERROR] Frontend dependencies are not installed.
  where npm >nul 2>nul
  if errorlevel 1 (
    echo Node.js and npm were not found. Install Node.js LTS and run START.bat again.
  ) else (
    echo Open a terminal in the project folder and run:
    echo   npm --prefix frontend install
  )
  echo.
  pause
  exit /b 1
)

if not exist "%BACKEND_DIR%\requirements.txt" (
  echo [ERROR] Backend requirements file is missing: %BACKEND_DIR%\requirements.txt
  pause
  exit /b 1
)

"%PYTHON%" -c "import fastapi, uvicorn, multipart, pypdf, docx, pptx, dotenv" >nul 2>nul
if errorlevel 1 (
  echo [ERROR] One or more Python backend dependencies are missing.
  echo Install them into this project's local environment with:
  echo   .venv\Scripts\python.exe -m pip install -r backend\requirements.txt
  echo Then run START.bat again.
  echo.
  pause
  exit /b 1
)

where powershell.exe >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Windows PowerShell is required to manage local app processes.
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo [ERROR] npm was not found. Install Node.js LTS, close this window, and run START.bat again.
  pause
  exit /b 1
)

set "STUDY_APP_ROOT=%APP_ROOT%"
set "STUDY_APP_URL=%APP_URL%"
set "STUDY_PYTHON=%PYTHON%"

echo [1/4] Selecting private loopback ports...
for /f "usebackq tokens=1,2" %%A in (`powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$listener=[System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,0);$listener.Start();$backend=$listener.LocalEndpoint.Port;$listener.Stop();$listener=[System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback,0);$listener.Start();$frontend=$listener.LocalEndpoint.Port;$listener.Stop();Write-Output ($backend.ToString()+' '+$frontend.ToString())"`) do (
  set "BACKEND_PORT=%%A"
  set "FRONTEND_PORT=%%B"
)
if not defined BACKEND_PORT (
  echo [ERROR] Could not reserve local application ports.
  pause
  exit /b 1
)
for %%P in (%BACKEND_PORT% %FRONTEND_PORT%) do (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "if (Get-NetTCPConnection -State Listen -LocalPort %%P -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }" >nul 2>nul
  if errorlevel 1 (
    echo [ERROR] Port %%P became busy during startup. Close the other app using it and retry.
    pause
    exit /b 1
  )
)
set "STUDY_BACKEND_URL=http://127.0.0.1:%BACKEND_PORT%"
set "APP_URL=http://127.0.0.1:%FRONTEND_PORT%/"
set "STUDY_APP_URL=%APP_URL%"
set "STUDY_BACKEND_PORT=%BACKEND_PORT%"
set "STUDY_FRONTEND_PORT=%FRONTEND_PORT%"

if not exist "%BACKEND_DIR%\data" mkdir "%BACKEND_DIR%\data" >nul 2>nul
if not exist "%BACKEND_DIR%\data\backups" mkdir "%BACKEND_DIR%\data\backups" >nul 2>nul
>"%BACKEND_DIR%\data\run-ports.txt" echo %BACKEND_PORT%,%FRONTEND_PORT%

echo [2/4] Starting FastAPI on 127.0.0.1:%BACKEND_PORT%...
start "Private Study Backend" /min powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -Command "$Host.UI.RawUI.WindowTitle='Private Study Backend'; Set-Location -LiteralPath $env:STUDY_APP_ROOT; $env:STUDY_HOST='127.0.0.1'; $env:STUDY_PORT=$env:STUDY_BACKEND_PORT; $env:STUDY_FRONTEND_ORIGIN='http://127.0.0.1:%FRONTEND_PORT%'; & $env:STUDY_PYTHON (Join-Path $env:STUDY_APP_ROOT 'backend\run_local.py'); if ($LASTEXITCODE -ne 0) { Write-Host ('Backend exited with code '+$LASTEXITCODE) -ForegroundColor Red }; Read-Host 'Backend stopped. Press Enter to close this window'"

echo [3/4] Starting Vite on loopback at %APP_URL%...
start "Private Study Frontend" /min powershell.exe -NoExit -NoProfile -ExecutionPolicy Bypass -Command "$Host.UI.RawUI.WindowTitle='Private Study Frontend'; Set-Location -LiteralPath (Join-Path $env:STUDY_APP_ROOT 'frontend'); $env:STUDY_BACKEND_URL='http://127.0.0.1:%BACKEND_PORT%'; npm run dev -- --host 127.0.0.1 --port %FRONTEND_PORT% --strictPort; if ($LASTEXITCODE -ne 0) { Write-Host ('Frontend exited with code '+$LASTEXITCODE) -ForegroundColor Red }; Read-Host 'Frontend stopped. Press Enter to close this window'"

echo [4/4] Waiting for local services and opening your browser...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $healthUrl='http://127.0.0.1:%BACKEND_PORT%/health'; $appUrl='http://127.0.0.1:%FRONTEND_PORT%/'; $ready=$false; for($i=0;$i -lt 40;$i++){ try{$r=Invoke-RestMethod -Uri $healthUrl -TimeoutSec 2; if($r.status -eq 'ok'){ $ready=$true; break }}catch{}; Start-Sleep -Milliseconds 500 }; if(-not $ready){ Write-Host 'Backend did not become ready. Check the Private Study Backend window.' -ForegroundColor Red; exit 2 }; $ready=$false; for($i=0;$i -lt 40;$i++){ try{$r=Invoke-WebRequest -Uri $appUrl -TimeoutSec 2 -UseBasicParsing; if($r.StatusCode -eq 200){ $ready=$true; break }}catch{}; Start-Sleep -Milliseconds 500 }; if(-not $ready){ Write-Host 'Frontend did not become ready. Check the Private Study Frontend window.' -ForegroundColor Red; exit 3 }; Start-Process $appUrl; Write-Host ('Study platform ready at '+$appUrl) -ForegroundColor Green"
if errorlevel 1 (
  echo.
  echo [ERROR] A local service did not start. Review its minimized PowerShell window.
  pause
  exit /b 1
)

echo.
echo Your private study platform is open in your default browser.
echo Address: %APP_URL%
echo Stop it using STOP.bat in the project folder.
echo Data remains on this computer under backend\data.
echo Keep the two minimized PowerShell service windows open while using the app.
echo.
pause
endlocal
