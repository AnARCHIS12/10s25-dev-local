@echo off
chcp 65001 >nul
echo Demarrage du serveur de developpement...
cd /d "%~dp0\.."
python server.py
pause