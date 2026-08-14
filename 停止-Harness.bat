@echo off
setlocal EnableExtensions
set "PORT=3080"
echo.
echo  ============================================
echo   DeepSeek Harness 停止中...
echo   正在结束端口 %PORT% 上的服务进程
echo  ============================================
echo.
set "KILLED="
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /R ":%PORT%.*LISTENING"') do (
  taskkill /PID %%P /T /F >nul 2>nul
  set "KILLED=1"
)
if defined KILLED (
  echo  [OK] 已停止 Harness
) else (
  echo  [!] 未发现运行中的 Harness（端口 %PORT% 无监听）
)
echo.
echo  窗口将在几秒后自动关闭...
ping -n 5 127.0.0.1 >nul
exit /b 0
