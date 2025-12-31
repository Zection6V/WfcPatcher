@echo off
setlocal enabledelayedexpansion

echo --------------------------------------------------
echo   WFC Patcher Batch - Drag and Drop NDS Files
echo --------------------------------------------------

REM If no file was provided (no drag & drop)
if "%~1"=="" (
    echo.
    echo Drag and drop .nds files onto this batch file.
    pause
    exit /b
)

REM Loop through all provided arguments (files)
for %%F in (%*) do (
    REM Get extension and normalize to lowercase
    set "ext=%%~xF"
    set "ext=!ext:~1!"
    set "ext=!ext:"=!"
    set "ext=!ext: =!"
    set "ext=!ext:~0,3!"
    set "ext=!ext!"

    REM Process only .nds files
    if /I "!ext!"=="nds" (
        echo.
        echo [OK] Processing: %%~nxF ...
        wfcpatcher "%%~fF" --domain wiilink24.com
    ) else (
        echo.
        echo [SKIP] %%~nxF is not .nds, skipping.
    )
)

echo.
echo All tasks completed!
pause
