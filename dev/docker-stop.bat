@echo off
chcp 65001 >nul

echo Arret des conteneurs Docker...
echo =================================

REM Aller au dossier docker
cd /d "%~dp0\..\docker"

REM Arreter et supprimer les conteneurs
docker compose down

echo.
echo Conteneurs arretes !
echo.
echo Pour redemarrer : dev\docker.bat
echo.
pause