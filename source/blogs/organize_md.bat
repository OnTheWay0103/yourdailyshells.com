@echo off
setlocal enabledelayedexpansion

:: 获取当前日期，格式为YYYY-MM-DD
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (
    set mm=%%a
    set dd=%%b
    set yy=%%c
)
:: 确保月份和日期是两位数
if %mm% LSS 10 set mm=0%mm%
if %dd% LSS 10 set dd=0%dd%
set current_date=%yy%-%mm%-%dd%

:: 查找一级子目录下的所有md文件，排除BEFORE.md和AFTER.md
for /r %%f in (*.md) do (
    :: 获取文件所在目录
    set "parent_dir=%%~dpf"
    set "parent_dir=!parent_dir:~0,-1!"
    
    :: 获取文件名（不包含扩展名）
    set "filename=%%~nf"
    
    :: 排除特定文件
    if not "!filename!"=="BEFORE" if not "!filename!"=="AFTER" (
        :: 创建新目录名（在父目录下）
        set "new_dir=!parent_dir!\!current_date!_!filename!"
        
        :: 创建新目录
        mkdir "!new_dir!"
        
        :: 移动文件到新目录并重命名为README.md
        move "%%f" "!new_dir!\README.md"
        
        echo 已处理文件: %%f -^> !new_dir!\README.md
    )
)

endlocal 