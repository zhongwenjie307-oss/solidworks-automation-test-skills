@echo off
chcp 936 >nul
title SolidWorks MCP Server
echo ==========================================
echo   SolidWorks MCP Server v2
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
echo [1/2] Checking dependencies...
%PYTHON_CMD% -c "import win32com.client" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing pywin32...
    %PYTHON_CMD% -m pip install pywin32 -q
)
%PYTHON_CMD% -c "import mcp" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing mcp SDK...
    %PYTHON_CMD% -m pip install mcp -q
)

echo [2/2] Environment check passed
echo.
echo ==========================================
echo   Starting MCP Server...
echo ==========================================
echo.
echo Notes:
echo   - This server communicates via stdio with MCP clients
echo   - Do not close this window directly
echo   - Supports 28 SolidWorks automation tools
echo.
echo Available tools:
echo   sw_create_box, sw_create_cylinder, sw_fillet, sw_shell
echo   sw_surface_loft, sw_surface_sweep, sw_thicken
echo   sw_save, sw_export, sw_screenshot
echo.
echo ==========================================
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"

cd /d "%SCRIPT_DIR%scripts"
%PYTHON_CMD% mcp_server_v2.py

if errorlevel 1 (
    echo.
    echo [ERROR] MCP Server exited abnormally
    pause
    exit /b 1
)
