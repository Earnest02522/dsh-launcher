@echo off
setlocal EnableExtensions
set "PORT=3080"
echo Stopping DeepSeek Harness (port %PORT%)...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /R ":%PORT%.*LISTENING"') do (
  taskkill /PID %%P /T /F >nul 2>nul
)
echo Done.

