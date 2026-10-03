@echo off
chcp 65001 >nul
title Desinstalador - SCREEN MODE

echo ========================================================
echo           DESINSTALADOR - SCREEN MODE
echo ========================================================
echo.

taskkill /f /im powershell.exe /fi "WINDOWTITLE eq SCREEN MODE*" 2>nul

set "TARGET_DIR=%LOCALAPPDATA%\ScreenMode"
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

del /f /q "%STARTUP_DIR%\SCREEN_MODE_Startup.vbs" 2>nul
del /f /q "%USERPROFILE%\Desktop\🍎 Screen Mac (155Hz).lnk" 2>nul
del /f /q "%USERPROFILE%\Desktop\💻 Screen Windows (155Hz).lnk" 2>nul

if exist "%TARGET_DIR%" rd /s /q "%TARGET_DIR%"

echo.
echo SCREEN MODE foi removido com sucesso do seu sistema.
echo.
pause
