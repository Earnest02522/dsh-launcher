@echo off
setlocal EnableExtensions
set "PORT=3080"
set "HS_URL=http://127.0.0.1:%PORT%"
echo.
echo  ============================================================
echo   DeepSeek Harness Launcher
echo  ============================================================
echo.

rem --- already running? just open the browser ---
echo  [..] checking port %PORT% ...
netstat -an | findstr /R ":%PORT%[^0-9].*LISTENING" >nul 2>nul
if not errorlevel 1 goto open

rem --- npx present? ---
where npx.cmd >nul 2>nul
if errorlevel 1 goto missing

rem --- check latest version on the registry (bounded time, offline-safe) ---
echo  [..] checking for updates ...
set "LATEST="
for /f "delims=" %%V in ('npm view @deepseek-ai/dsh version --fetch-timeout=5000 --fetch-retries=0 2^>nul') do if not defined LATEST set "LATEST=%%V"

rem --- find the newest locally cached dsh package (several stale copies can exist) ---
set "PKGJSON="
for /f "delims=" %%D in ('dir /b /a:d /o-d "%LOCALAPPDATA%\npm-cache\_npx" 2^>nul') do (
  if not defined PKGJSON if exist "%LOCALAPPDATA%\npm-cache\_npx\%%D\node_modules\@deepseek-ai\dsh\package.json" set "PKGJSON=%LOCALAPPDATA%\npm-cache\_npx\%%D\node_modules\@deepseek-ai\dsh\package.json"
)
set "LOCALVER="
if defined PKGJSON (
  for /f "delims=" %%V in ('node -e "var p=require(process.argv[1]);console.log(p.version||'')" "%PKGJSON%"') do if not defined LOCALVER set "LOCALVER=%%V"
)

rem --- decide which exact version to run, and whether an install is needed ---
set "SPEC=@deepseek-ai/dsh"
set "OFFLINE="
set "NEED_INSTALL="
if not defined LATEST (
  if not defined LOCALVER (
    echo.
    echo  [!!] cannot reach the registry and no cached version is installed
    echo  [!!] please connect to the internet for the first run
    pause
    exit /b 1
  )
  echo  [..] cannot reach the registry - using cached version %LOCALVER%
  set "SPEC=@deepseek-ai/dsh@%LOCALVER%"
  set "OFFLINE=--offline"
) else if not defined LOCALVER (
  echo  [..] first run detected - installing %LATEST% ...
  set "SPEC=@deepseek-ai/dsh@%LATEST%"
  set "NEED_INSTALL=1"
) else (
  node -e "var a=process.argv[1].split('-')[0].split('.').map(Number),b=process.argv[2].split('-')[0].split('.').map(Number);for(var i=0;i<Math.max(a.length,b.length);i++){if((a[i]||0)<(b[i]||0))process.exit(1);if((a[i]||0)>(b[i]||0))process.exit(2)}process.exit(0)" "%LOCALVER%" "%LATEST%"
  if errorlevel 2 (
    echo  [..] cached version %LOCALVER% is newer than registry %LATEST%
    echo  [..] keeping the cached version ...
    set "SPEC=@deepseek-ai/dsh@%LOCALVER%"
  ) else if errorlevel 1 (
    echo  [..] update found: %LOCALVER% -^> %LATEST%
    echo  [..] downloading and installing the update ...
    set "SPEC=@deepseek-ai/dsh@%LATEST%"
    set "NEED_INSTALL=1"
  ) else (
    echo  [..] already the latest version ^(%LATEST%^)
    set "SPEC=@deepseek-ai/dsh@%LATEST%"
  )
)

rem --- install updates in THIS window so progress and errors are visible ---
if defined NEED_INSTALL (
  echo.
  echo  [..] installing %SPEC% - this can take a few minutes ...
  echo  [..] the status window stays open until the service is ready
  echo.
  call npx --yes %SPEC% --version
  if errorlevel 1 (
    echo.
    echo  [!!] install failed - see the messages above
    echo  [!!] retry manually:  npx --yes %SPEC% web
    pause
    exit /b 1
  )
  echo.
  echo  [OK] %SPEC% installed
)

rem --- start the service detached & hidden (window can close, port stays) ---
set "SVC_PID="
for /f "delims=" %%P in ('powershell -NoProfile -Command "(Start-Process -FilePath 'cmd.exe' -ArgumentList '/d','/c','npx --yes %OFFLINE% %SPEC% web' -WindowStyle Hidden -PassThru).Id"') do set "SVC_PID=%%P"
if not defined SVC_PID (
  echo  [!!] failed to launch the service process
  pause
  exit /b 1
)

rem --- wait until the service listens on the port ---
echo  [..] waiting for the service on port %PORT% ...
set /a N=0
:probe
  ping -n 1 127.0.0.1 >nul
  netstat -an | findstr /R ":%PORT%[^0-9].*LISTENING" >nul 2>nul
  if not errorlevel 1 goto open
  set /a N+=1
  if %N% gtr 30 (
    powershell -NoProfile -Command "if (Get-Process -Id %SVC_PID% -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }" >nul 2>nul
    if errorlevel 1 goto died
  )
  set /a M=%N% %% 30
  if %M% equ 0 echo  [..] still waiting (about %N% s) ...
  if %N% lss 600 goto probe
echo.
echo  [!!] service did not respond within 600s
goto fail

:died
echo.
echo  [!!] the service process exited before the port came up
goto fail

:fail
echo  [!!] start it manually to see the error:
echo         npx --yes %OFFLINE% %SPEC% web
echo.
pause
exit /b 1

:open
echo  [OK] opening %HS_URL% ...
start "" "%HS_URL%"
echo  [OK] this window closes now; the service keeps running in the background
exit /b 0

:missing
echo  [!!] npx not found - please install Node.js first
pause
exit /b 1