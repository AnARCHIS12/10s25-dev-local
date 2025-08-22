@echo off

echo 🛑 Arrêt des conteneurs Docker...
echo =================================

REM Aller au dossier docker
cd /d "%~dp0\..\docker"

REM Arrêter et supprimer les conteneurs
docker compose down

echo.
echo ✅ Conteneurs arrêtés !
echo.
echo 🔄 Pour redémarrer : dev\docker.bat
echo.
pause