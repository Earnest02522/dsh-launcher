@echo off
setlocal EnableExtensions
set "PORT=3080"
set "HS_URL=http://127.0.0.1:%PORT%"
rem already running? just open browser
netstat -an | findstr /R ":%PORT%.*LISTENING" >nul 2>nul
if not errorlevel 1 goto open
rem npx present?
where npx.cmd >nul 2>nul
if errorlevel 1 goto missing
rem launch service hidden (no window)
start "" /b cmd /c "npx @deepseek-ai/dsh web"
set /a N=0
:probe
  ping -n 1 127.0.0.1 >nul
  netstat -an | findstr /R ":%PORT%.*LISTENING" >nul 2>nul
  if not errorlevel 1 goto open
  set /a N+=1
  if %N% lss 120 goto probe
:open
start "" "%HS_URL%"
exit /b 0
:missing
exit /b 1
