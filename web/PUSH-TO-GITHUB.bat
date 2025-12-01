@echo off
echo ========================================
echo    JetStream - Git Push Script
echo ========================================
echo.

:: Check if git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed!
    echo Please install Git from: https://git-scm.com/downloads
    pause
    exit /b 1
)

:: Change to web directory
cd /d "%~dp0"

echo Current directory: %cd%
echo.

:: Initialize git if not already initialized
if not exist ".git" (
    echo [1/6] Initializing Git repository...
    git init
    echo.
)

:: Create README if it doesn't exist
if not exist "README.md" (
    echo # JetStream Web App > README.md
)

echo [2/6] Adding files to Git...
git add .
echo.

echo [3/6] Committing changes...
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Update JetStream Web App

git commit -m "%commit_msg%"
if %errorlevel% neq 0 (
    echo No changes to commit or commit failed.
)
echo.

echo [4/6] Setting branch to main...
git branch -M main
echo.

echo [5/6] Setting remote origin...
set /p repo_url="Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): "
if "%repo_url%"=="" (
    echo [ERROR] Repository URL is required!
    pause
    exit /b 1
)

:: Remove existing origin if it exists
git remote remove origin 2>nul

git remote add origin %repo_url%
echo.

echo [6/6] Pushing to GitHub...
echo.
echo Note: You may be prompted for your GitHub credentials.
echo.

git push -u origin main --force

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Successfully pushed to GitHub!
    echo ========================================
    echo.
    echo Repository: %repo_url%
    echo Branch: main
    echo.
) else (
    echo.
    echo [ERROR] Push failed!
    echo Please check your credentials and repository URL.
    echo.
)

pause
