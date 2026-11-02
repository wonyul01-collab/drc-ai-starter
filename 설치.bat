@echo off
chcp 65001 >nul
title 디알컴퍼니 클로드 자동화 키트 설치
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
