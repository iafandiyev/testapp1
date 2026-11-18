@echo off
chcp 65001 >nul
title Simple Notes - GitHub Upload

echo ========================================
echo       SIMPLE NOTES - GITHUB UPLOAD
echo ========================================

if not exist ".git" (
    git init
)

git branch -M main

git remote get-url origin >nul 2>&1

if errorlevel 1 (
    git remote add origin https://github.com/iafandiyev/testapp1.git
) else (
    git remote set-url origin https://github.com/iafandiyev/testapp1.git
)

git add .

git commit -m "Create Simple Notes iOS application"

if errorlevel 1 (
    echo.
    echo No new changes to commit or commit failed.
    pause
    exit /b 1
)

git push -u origin main

if errorlevel 1 (
    echo.
    echo GitHub upload failed. Check your login and repository access.
    pause
    exit /b 1
)

echo.
echo ========================================
echo       SUCCESS - CODE UPLOADED
echo ========================================
echo.
echo Check:
echo https://github.com/iafandiyev/testapp1
echo.
echo GitHub Actions:
echo https://github.com/iafandiyev/testapp1/actions
echo.
pause