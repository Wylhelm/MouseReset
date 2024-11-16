@echo off
SET "SCRIPTPATH=%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTPATH%Uninstall.ps1"
exit /b %ERRORLEVEL%
