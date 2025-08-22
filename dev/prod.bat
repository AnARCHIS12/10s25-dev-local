@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo Preparation pour la production...
echo ====================================

REM Verifier qu'on est dans le bon dossier
if not exist "index.html" (
    echo Erreur: Lancez ce script depuis la racine du projet ^(ou se trouve index.html^)
    pause
    exit /b 1
)

echo Restauration du menu avec conditions SSI pour Apache...
(
echo ^<!-- Éléments de menu principal personnalisé pour ce site  --^>^<!--#config errmsg="" --^>
echo ^<li^<!--#if expr="$REQUEST_URI = '/local/visuels.html'" --^> class="selected"^<!--#endif --^>^>^<a href="/local/visuels.html"^>Visuels^</a^>^</li^>
echo ^<li class="dropdown^<!--#if expr="$REQUEST_URI = /doleances/" --^> selected^<!--#endif --^>"^>
echo 	^<a href="#" class="disabled"^>Doléances ▾^</a^>
echo 	^<ul class="submenu"^>
echo 		^<li^<!--#if expr="$REQUEST_URI = '/local/formulaire-doleances.html'" --^> class="selected"^<!--#endif --^>^>^<a href="/local/formulaire-doleances.html"^>Formulaire de Doléances^</a^>^</li^>
echo 		^<li^<!--#if expr="$REQUEST_URI = '/local/doleances.html'" --^> class="selected"^<!--#endif --^>^>^<a href="/local/doleances.html"^>Cahier de Doléances^</a^>^</li^>
echo 	^</ul^>
echo ^</li^>
) > "local\ssi\menu_top.shtml"

echo Suppression des fichiers de developpement...
if exist "server.py" (
    del "server.py"
    echo    - server.py supprimé
)

echo Mise a jour du .htaccess pour Apache de production...
(
echo Options +Includes +FollowSymLinks
echo AddType text/html .shtml .html
echo AddOutputFilter INCLUDES .shtml .html
echo AddHandler server-parsed .html
echo DirectoryIndex index.html
echo XBitHack on
echo.
echo # Configuration pour la production
echo ^<IfModule mod_headers.c^>
echo     Header always set X-Content-Type-Options nosniff
echo     Header always set X-Frame-Options DENY
echo     Header always set X-XSS-Protection "1; mode=block"
echo ^</IfModule^>
echo.
echo # Cache pour les ressources statiques
echo ^<IfModule mod_expires.c^>
echo     ExpiresActive On
echo     ExpiresByType text/css "access plus 1 month"
echo     ExpiresByType application/javascript "access plus 1 month"
echo     ExpiresByType image/png "access plus 1 month"
echo     ExpiresByType image/svg+xml "access plus 1 month"
echo     ExpiresByType image/gif "access plus 1 month"
echo ^</IfModule^>
) > .htaccess

echo Regeneration finale des groupes...
where php >nul 2>&1
if !errorlevel! == 0 (
    if exist "src\update_groups.php" (
        cd src
        php update_groups.php >nul 2>&1 && echo    Groupes regeneres
        cd ..
    )
) else (
    echo    PHP non disponible, groupes non regeneres
)

echo Creation du fichier de deploiement...
(
echo # Déploiement en production
echo.
echo ## Prérequis serveur
echo - Apache avec mod_include activé
echo - PHP ^(optionnel, pour la génération des groupes^)
echo.
echo ## Installation
echo 1. Copier tous les fichiers sur le serveur
echo 2. Vérifier que mod_include est activé :
echo    ```bash
echo    a2enmod include
echo    systemctl reload apache2
echo    ```
echo.
echo ## Structure déployée
echo - Fichiers .htaccess configures pour Apache
echo - Menu avec conditions SSI pour selection active
echo - Configuration de securite et cache
echo - Groupes generes ^(si PHP disponible^)
echo.
echo ## Test
echo - Vérifier que les includes SSI fonctionnent
echo - Vérifier que le menu s'affiche correctement
echo - Vérifier que la sidebar contient tous les groupes
echo.
echo ## Maintenance
echo Pour mettre à jour les groupes :
echo ```bash
echo cd src/
echo php update_groups.php
echo ```
) > DEPLOIEMENT.md

echo.
echo Preparation production terminee !
echo.
echo Le projet est pret pour le deploiement Apache
echo.
echo Changements effectues :
echo    - Menu restaure avec conditions SSI
echo    - server.py supprime
echo    - .htaccess optimise pour la production
echo    - Groupes regeneres
echo    - Documentation de deploiement creee
echo.
echo Voir DEPLOIEMENT.md pour les instructions
echo.
echo Pour revenir en mode dev : dev\setup.bat
echo.
pause