@echo off
setlocal EnableExtensions
set "PORT=3080"
echo.
echo  ================================================================================
echo   DeepSeek Harness is stopping...
echo   Stopping the service process on port %PORT%
echo  ================================================================================
echo.
set "KILLED="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /R ":%PORT%.*LISTENING"') do (
  taskkill /PID %%P /T /F >nul 2>nul
  set "KILLED=1"
)
if defined KILLED (
  echo  [OK] Harness has been stopped
) else (
  echo  [!] No running Harness found - nothing listening on port %PORT%
)
echo.
echo  The window will close automatically in a few seconds...
ping -n 3 127.0.0.1 >nul
exit /b 0