@echo off
setlocal enabledelayedexpansion

echo 🚀 Configuration automatique du projet site
echo ================================================

REM Vérifier qu'on est dans le bon dossier
if not exist "index.html" (
    echo ❌ Erreur: Lancez ce script depuis la racine du projet ^(où se trouve index.html^)
    pause
    exit /b 1
)

echo 📁 Création des dossiers nécessaires...
if not exist "local\ssi" mkdir "local\ssi"
if not exist "global\ssi" mkdir "global\ssi"
if not exist "dev" mkdir "dev"

echo 📝 Création du fichier .htaccess principal...
(
echo Options +Includes +FollowSymLinks
echo AddType text/html .shtml .html
echo AddOutputFilter INCLUDES .shtml .html
echo AddHandler server-parsed .html
echo DirectoryIndex index.html
echo XBitHack on
) > .htaccess

echo 📝 Création du fichier .htaccess pour SSI legacy...
echo SSILegacyExprParser on > "local\ssi\.htaccess"

echo 📝 Correction du menu ^(suppression des conditions SSI^)...
(
echo ^<!-- Éléments de menu principal personnalisé pour ce site --^>
echo ^<li^>^<a href="/local/visuels.html"^>Visuels^</a^>^</li^>
echo ^<li class="dropdown"^>
echo 	^<a href="#" class="disabled"^>Doléances ▾^</a^>
echo 	^<ul class="submenu"^>
echo 		^<li^>^<a href="/local/formulaire-doleances.html"^>Formulaire de Doléances^</a^>^</li^>
echo 		^<li^>^<a href="/local/doleances.html"^>Cahier de Doléances^</a^>^</li^>
echo 	^</ul^>
echo ^</li^>
) > "local\ssi\menu_top.shtml"

echo 📝 Création des fichiers SSI manquants...
if not exist "local\ssi\emails.shtml" (
    echo ^<a href="mailto:contact@example.com"^>contact@example.com^</a^> > "local\ssi\emails.shtml"
)

if not exist "local\ssi\gpg.shtml" (
    echo Clé GPG à configurer > "local\ssi\gpg.shtml"
)

echo 🐍 Création du serveur Python avec SSI...
(
echo #!/usr/bin/env python3
echo import http.server
echo import socketserver
echo import os
echo import re
echo.
echo class SSIHandler^(http.server.SimpleHTTPRequestHandler^):
echo     def do_GET^(self^):
echo         if self.path.endswith^('.html'^) or self.path == '/':
echo             try:
echo                 if self.path == '/':
echo                     filepath = 'index.html'
echo                 else:
echo                     filepath = self.path.lstrip^('/'^)
echo                 
echo                 with open^(filepath, 'r', encoding='utf-8'^) as f:
echo                     content = f.read^(^)
echo                 
echo                 content = self.process_ssi^(content^)
echo                 
echo                 self.send_response^(200^)
echo                 self.send_header^('Content-type', 'text/html; charset=utf-8'^)
echo                 self.end_headers^(^)
echo                 self.wfile.write^(content.encode^('utf-8'^)^)
echo             except FileNotFoundError:
echo                 super^(^).do_GET^(^)
echo         else:
echo             super^(^).do_GET^(^)
echo     
echo     def process_ssi^(self, content^):
echo         pattern = r'^<!--#include virtual="^([^"]+^)" --^>'
echo         
echo         def replace_include^(match^):
echo             include_path = match.group^(1^)
echo             try:
echo                 with open^(include_path, 'r', encoding='utf-8'^) as f:
echo                     return f.read^(^)
echo             except FileNotFoundError:
echo                 return f'^<!-- File not found: {include_path} --^>'
echo         
echo         # Supprimer les directives SSI non supportées
echo         content = re.sub^(r'^<!--#config[^^>]*--^>', '', content^)
echo         content = re.sub^(r'^<!--#if[^^>]*--^>', '', content^)
echo         content = re.sub^(r'^<!--#endif[^^>]*--^>', '', content^)
echo         content = re.sub^(r'^<!--#echo[^^>]*--^>', '', content^)
echo         
echo         return re.sub^(pattern, replace_include, content^)
echo.
echo PORT = 8000
echo with socketserver.TCPServer^(^("localhost", PORT^), SSIHandler^) as httpd:
echo     print^(f"Server running at http://localhost:{PORT}"^)
echo     httpd.serve_forever^(^)
) > server.py

echo 🔧 Génération du fichier groupes.shtml...
where php >nul 2>&1
if !errorlevel! == 0 (
    if exist "src\update_groups.php" (
        cd src
        php update_groups.php >nul 2>&1 || echo ⚠️  Erreur lors de la génération des groupes ^(normal si pas de PHP^)
        cd ..
    )
) else (
    echo ⚠️  PHP non trouvé, création d'un fichier groupes.shtml basique...
    (
    echo ^<ul class="sidebar-section-1"^>
    echo     ^<li^>
    echo         ^<h3 class="font-yellow"^>Réseaux sociaux^</h3^>
    echo         ^<ul class="sidebar-section-2"^>
    echo             ^<li^>
    echo                 ^<ul^>
    echo                     ^<li class="telegram"^>
    echo                         ^<p^>Telegram^</p^>
    echo                         ^<ul^>
    echo                             ^<li^>^<a href="https://t.me/+B5CJp-RUGpAzMmQ8" target="_blank" rel="me"^>+B5CJp-RUGpAzMmQ8^</a^>^</li^>
    echo                         ^</ul^>
    echo                     ^</li^>
    echo                 ^</ul^>
    echo             ^</li^>
    echo         ^</ul^>
    echo     ^</li^>
    echo ^</ul^>
    ) > "global\ssi\groupes.shtml"
)

echo 📝 Création du script de démarrage...
(
echo @echo off
echo echo 🚀 Démarrage du serveur de développement...
echo cd /d "%%~dp0\.."
echo python server.py
echo pause
) > "dev\start.bat"

echo.
echo ✅ Configuration terminée !
echo.
echo 🎯 Pour démarrer le serveur :
echo    dev\start.bat
echo    ou
echo    python server.py
echo.
echo 🌐 Puis ouvrir : http://localhost:8000
echo.
echo 📋 Fichiers créés/modifiés :
echo    - .htaccess ^(SSI activés^)
echo    - local\ssi\.htaccess ^(SSI legacy^)
echo    - local\ssi\menu_top.shtml ^(corrigé^)
echo    - server.py ^(serveur Python avec SSI^)
echo    - dev\start.bat ^(script de démarrage^)
echo.
pause