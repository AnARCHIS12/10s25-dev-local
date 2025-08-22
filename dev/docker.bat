@echo off
chcp 65001 >nul
setlocal

echo Demarrage de l'environnement Docker...
echo ========================================

REM Aller à la racine du projet
cd /d "%~dp0\.."

REM Verifier que Docker est installe
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker n'est pas installe
    echo    Installez Docker : https://docs.docker.com/get-docker/
    pause
    exit /b 1
)

REM Verifier que Docker Compose est disponible
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Compose n'est pas disponible
    pause
    exit /b 1
)

REM Verifier que les fichiers Docker existent
if not exist "docker\Dockerfile" (
    echo Fichiers Docker manquants dans le dossier docker\
    pause
    exit /b 1
)
if not exist "docker\compose.yaml" (
    echo Fichiers Docker manquants dans le dossier docker\
    pause
    exit /b 1
)

echo Dossier de travail: %cd%
echo Preparation pour la production Docker...

REM Preparer pour la production (SSI Apache complets)
if exist "dev\prod.bat" (
    echo    Execution de dev\prod.bat...
    call "dev\prod.bat"
) else if exist "dev\prod.sh" (
    echo    Execution de dev\prod.sh...
    bash "dev\prod.sh"
)

echo.
echo Construction et demarrage des conteneurs...
cd docker

REM Arrêter les conteneurs existants
docker compose down >nul 2>&1

REM Construire et démarrer
docker compose up --build -d

echo.
echo Conteneurs demarres !
echo.
echo Acces au site :
echo    - Apache (production) : http://localhost:8080
echo    - Live reload (dev)   : http://localhost:3000
echo    - BrowserSync panel   : http://localhost:3001
echo.
echo Commandes utiles :
echo    docker compose logs -f     # Voir les logs
echo    docker compose down        # Arreter les conteneurs
echo    docker compose restart     # Redemarrer
echo.
echo Pour arreter : dev\docker-stop.bat
echo.
pause