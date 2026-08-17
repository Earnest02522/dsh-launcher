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
netstat -an | findstr /R ":%PORT%.*LISTENING" >nul 2>nul
if not errorlevel 1 goto open

rem --- npx present? ---
where npx.cmd >nul 2>nul
if errorlevel 1 goto missing

rem --- check latest version on the registry (bounded time, offline-safe) ---
echo  [..] checking for updates ...
set "LATEST="
for /f "delims=" %%V in ('npm view @deepseek-ai/dsh version --fetch-timeout=5000 --fetch-retries=0 2^>nul') do if not defined LATEST set "LATEST=%%V"

rem --- find the locally cached dsh package ---
set "PKGJSON="
for /d %%D in ("%LOCALAPPDATA%\npm-cache\_npx\*") do (
  if exist "%%D\node_modules\@deepseek-ai\dsh\package.json" set "PKGJSON=%%D\node_modules\@deepseek-ai\dsh\package.json"
)
set "LOCALVER="
if defined PKGJSON (
  for /f "delims=" %%V in ('node -e "var p=require(process.argv[1]);console.log(p.version||'')" "%PKGJSON%"') do set "LOCALVER=%%V"
)

rem --- print an update-specific status, then start ---
if not defined LATEST (
  echo  [..] cannot reach the registry - using the cached version
  echo  [..] starting DeepSeek Harness ...
) else if not defined LOCALVER (
  echo  [..] first run detected - downloading and installing ...
) else (
  node -e "var a=process.argv[1].split('-')[0].split('.').map(Number),b=process.argv[2].split('-')[0].split('.').map(Number);for(var i=0;i<Math.max(a.length,b.length);i++){if((a[i]||0)<(b[i]||0))process.exit(1);if((a[i]||0)>(b[i]||0))process.exit(2)}process.exit(0)" "%LOCALVER%" "%LATEST%"
  if errorlevel 2 (
    echo  [..] local version %LOCALVER% is newer than registry %LATEST%
    echo  [..] starting DeepSeek Harness ...
  ) else if errorlevel 1 (
    echo  [..] update found: %LOCALVER% -^> %LATEST%
    echo  [..] updating and starting automatically ...
  ) else (
    echo  [..] already the latest version ^(%LATEST%^)
    echo  [..] starting DeepSeek Harness ...
  )
)

rem --- start the service detached & hidden (window can close, port stays) ---
powershell -NoProfile -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/d','/c','npx --yes @deepseek-ai/dsh web' -WindowStyle Hidden"

rem --- wait until the service listens on the port ---
echo  [..] waiting for the service on port %PORT% ...
set /a N=0
:probe
  ping -n 1 127.0.0.1 >nul
  netstat -an | findstr /R ":%PORT%.*LISTENING" >nul 2>nul
  if not errorlevel 1 goto open
  set /a N+=1
  if %N% lss 120 goto probe
echo  [!!] service did not respond within 120s - opening browser anyway

:open
echo  [OK] opening %HS_URL% ...
start "" "%HS_URL%"
echo  [OK] this window closes now; the service keeps running in the background
exit /b 0

:missing
echo  [!!] npx not found - please install Node.js first
pause
exit /b 1