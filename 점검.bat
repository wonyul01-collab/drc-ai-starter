@echo off
chcp 65001 >nul
title DRC Claude kit check
set "DRC_KIT_DIR=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create([IO.File]::ReadAllText($env:DRC_KIT_DIR + 'install.ps1', [Text.Encoding]::UTF8))) -OnlyCheck"
echo.
pause
