@echo off
chcp 936 >nul
title SolidWorks Automation Test
echo ==========================================
echo   SolidWorks Automation Skill - Run All Tests
echo ==========================================
echo.

REM Find Python executable
set "PYTHON_CMD="
for %%C in (python python3 py) do (
    %%C --version >nul 2>&1
    if not errorlevel 1 (
        set "PYTHON_CMD=%%C"
        goto :found_python
    )
)

if "%PYTHON_CMD%"=="" (
    echo [ERROR] Python not found.
    echo Please install Python 3.8+ and add to PATH.
    pause
    exit /b 1
)

:found_python
echo [INFO] Using Python: %PYTHON_CMD%

REM Install dependencies
echo [1/3] Checking dependencies...
%PYTHON_CMD% -c "import win32com.client" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing pywin32...
    %PYTHON_CMD% -m pip install pywin32 -q
)

echo [2/3] Environment check passed
echo.

REM Create output directory (use script parent dir)
set "SCRIPT_DIR=%~dp0"
set "OUTPUT_DIR=%SCRIPT_DIR%output"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo [3/3] Running tests...
echo ==========================================
echo.

REM Run test script
cd /d "%SCRIPT_DIR%scripts"
%PYTHON_CMD% run_all_verified_tests.py --output-dir "%OUTPUT_DIR%"

if errorlevel 1 (
    echo.
    echo [ERROR] Test execution failed
    pause
    exit /b 1
)

echo.
echo ==========================================
echo   All tests completed!
echo ==========================================
echo.
echo Output files: %OUTPUT_DIR%
echo.
pause
