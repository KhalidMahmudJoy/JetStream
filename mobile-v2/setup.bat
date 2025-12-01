@echo off
echo ========================================
echo JetStream Mobile v2 - Flutter Setup
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo.
    echo Please install Flutter from: https://docs.flutter.dev/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo [1/5] Checking Flutter installation...
flutter --version
echo.

echo [2/5] Running Flutter Doctor...
flutter doctor
echo.

echo [3/5] Cleaning previous builds...
flutter clean
echo.

echo [4/5] Getting dependencies...
flutter pub get
echo.

echo [5/5] Analyzing code...
flutter analyze
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Connect an Android device or start an emulator
echo 2. Run: flutter run
echo 3. Or build APK: flutter build apk --release
echo.
echo For more information, see SETUP_INSTRUCTIONS.md
echo.
pause
