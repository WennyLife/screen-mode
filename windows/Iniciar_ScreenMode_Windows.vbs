Set WshShell = CreateObject("WScript.Shell")
scriptPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.Run "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptPath & "\ScreenMode_Tray.ps1""", 0, False
