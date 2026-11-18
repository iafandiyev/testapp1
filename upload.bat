
@echo off
chcp 65001 >nul
title Simple Notes GitHub Upload

echo ========================================
echo       SIMPLE NOTES - GITHUB UPLOAD
echo ========================================

where git >nul 2>&1
if errorlevel 1 (
    echo Git is not installed!
    pause
    exit /b 1
)

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

git diff --cached --quiet
if not errorlevel 1 (
    echo No changes to upload.
    pause
    exit /b 0
)

git commit -m "Fix Simple Notes iOS build"

if errorlevel 1 (
    echo Commit failed!
    pause
    exit /b 1
)

git push -u origin main

if errorlevel 1 (
    echo GitHub push failed!
    pause
    exit /b 1
)

echo.
echo Upload successful!
echo https://github.com/iafandiyev/testapp1/actions
pause
