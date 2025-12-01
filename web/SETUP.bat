@echo off
title JetStream Setup
color 0A

:: Change to the script's directory
cd /d "%~dp0"

cls
echo.
echo ========================================
echo    JetStream Web App - Quick Setup
echo ========================================
echo.
echo Current directory: %CD%
echo.
echo Please wait...
echo.

:: Check if package.json exists
if not exist "package.json" (
    color 0C
    echo.
    echo [ERROR] package.json not found!
    echo.
    echo Make sure you're running this script from the web folder.
    echo Current location: %CD%
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Check if Node.js is installed
echo Checking for Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    color 0C
    echo.
    echo [ERROR] Node.js is not installed!
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo Download and install the LTS version, then run this setup again.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo [OK] Node.js found!
echo.

echo [1/3] Checking Node.js version...
echo Node.js version:
node --version
echo.
echo npm version:
npm --version
echo.

:: Check if already installed
if exist "node_modules\" (
    echo.
    echo [INFO] Dependencies already installed!
    echo.
    choice /C YN /M "Do you want to reinstall dependencies"
    if errorlevel 2 goto :skip_install
    echo.
    echo Removing old node_modules...
    rmdir /s /q node_modules 2>nul
)

echo.
echo [2/3] Installing dependencies...
echo This may take 2-5 minutes. Please wait...
echo.

call npm install

if %errorlevel% neq 0 (
    color 0C
    echo.
    echo ========================================
    echo   [ERROR] Installation Failed!
    echo ========================================
    echo.
    echo Please check:
    echo 1. Internet connection
    echo 2. npm configuration
    echo 3. Try running: npm cache clean --force
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:skip_install
echo.
echo [3/3] Setup complete!
echo.
color 0A
echo ========================================
echo   Installation Successful!
echo ========================================
echo.
echo Next step: Double-click START.bat to run the app
echo.
echo Press any key to exit...
pause >nul
