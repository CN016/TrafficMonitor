@echo off
setlocal enabledelayedexpansion

REM 切换到 bat 文件所在目录
cd /d "%~dp0"

REM 检查是否为 Git 仓库
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERROR] 当前目录不是 Git 仓库
    pause
    exit /b 1
)

REM 添加所有新增、修改、删除文件
git add -A

REM 统计暂存区文件数量
set count=0
for /f "delims=" %%f in ('git diff --cached --name-only') do (
    set /a count+=1
)

REM 没有文件变化则退出
if !count! EQU 0 (
    echo [INFO] 没有需要提交的文件
    pause
    exit /b 0
)

REM 获取当前时间
for /f "tokens=1-3 delims=/- " %%a in ("%date%") do (
    set gitdate=%date%
)

set gittime=%time:~0,5%
set gittime=%gittime: =0%

REM Commit 消息
set "message=%date% %gittime% 提交了 !count! 个文件"

echo.
echo ========================================
echo Commit: !message!
echo ========================================
echo.

REM 提交
git commit -m "!message!"
if errorlevel 1 (
    echo.
    echo [ERROR] Git commit 失败
    pause
    exit /b 1
)

REM Push 到当前分支对应的远程
git push
if errorlevel 1 (
    echo.
    echo [ERROR] Git push 失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo [SUCCESS] 提交并推送成功
echo ========================================
echo !message!
echo.

pause