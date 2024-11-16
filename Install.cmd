@echo off
SET "SCRIPTPATH=%~dp0"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTPATH%Install.ps1"
exit /b %ERRORLEVEL%
