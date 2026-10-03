@echo off
chcp 65001 >nul
title Instalador - SCREEN MODE

echo ========================================================
echo             INSTALADOR - SCREEN MODE (Windows)
echo ========================================================
echo.
echo Instalando o SCREEN MODE no seu sistema...
echo.

set "TARGET_DIR=%LOCALAPPDATA%\ScreenMode"

:: Fechar qualquer instância anterior
taskkill /f /im powershell.exe /fi "WINDOWTITLE eq SCREEN MODE*" 2>nul

:: Criar diretório de destino
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: Copiar arquivos do aplicativo
copy /y "%~dp0SwitchInput.ps1" "%TARGET_DIR%\" >nul
copy /y "%~dp0ScreenMode_Tray.ps1" "%TARGET_DIR%\" >nul
copy /y "%~dp0Iniciar_ScreenMode_Windows.vbs" "%TARGET_DIR%\" >nul
copy /y "%~dp0Screen_Mac.bat" "%TARGET_DIR%\" >nul
copy /y "%~dp0Screen_Windows.bat" "%TARGET_DIR%\" >nul

:: Criar atalho na Inicialização do Windows (shell:startup)
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
copy /y "%~dp0Iniciar_ScreenMode_Windows.vbs" "%STARTUP_DIR%\SCREEN_MODE_Startup.vbs" >nul

:: Criar atalho na Área de Trabalho para Screen Mac com tecla de atalho Ctrl+Alt+1
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\🍎 Screen Mac (155Hz).lnk'); $s.TargetPath = '%TARGET_DIR%\Screen_Mac.bat'; $s.Hotkey = 'CTRL+ALT+1'; $s.WindowStyle = 7; $s.Save()"

:: Criar atalho na Área de Trabalho para Screen Windows com tecla de atalho Ctrl+Alt+2
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\💻 Screen Windows (155Hz).lnk'); $s.TargetPath = '%TARGET_DIR%\Screen_Windows.bat'; $s.Hotkey = 'CTRL+ALT+2'; $s.WindowStyle = 7; $s.Save()"

:: Iniciar o aplicativo agora na bandeja
wscript.exe "%TARGET_DIR%\Iniciar_ScreenMode_Windows.vbs"

echo.
echo ========================================================
echo          INSTALAÇÃO CONCLUÍDA COM SUCESSO!
echo ========================================================
echo.
echo 1. O ícone do SCREEN MODE já está ativo na bandeja (perto do relógio).
echo 2. Ele vai iniciar automaticamente sempre que ligar o Windows.
echo 3. ATALHOS DE TECLADO ATIVOS NO WINDOWS:
echo    - Ctrl + Alt + 1  (ou Alt + Win + 1) ➔ Volta para o Mac
echo    - Ctrl + Alt + 2  (ou Alt + Win + 2) ➔ Vai para o Windows
echo 4. Atalhos criados na sua Área de Trabalho:
echo    - 🍎 Screen Mac (155Hz)
echo    - 💻 Screen Windows (155Hz)
echo.
pause
