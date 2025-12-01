@echo off
:: Change to the script's directory
cd /d "%~dp0"

echo ========================================
echo    Starting JetStream Web App...
echo ========================================
echo.
echo Current directory: %CD%
echo.

:: Check if node_modules exists
if not exist "node_modules\" (
    echo [WARNING] Dependencies not installed!
    echo Please run SETUP.bat first to install dependencies.
    echo.
    pause
    exit /b 1
)

:: Start the development server
echo Starting development server...
echo The app will open automatically in your browser.
echo.
echo Press Ctrl+C to stop the server.
echo.

start http://localhost:3000
npm run dev

pause
