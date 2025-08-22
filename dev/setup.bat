@echo off
chcp 65001 >nul
echo Configuration automatique du projet site
echo ================================================

if not exist "index.html" (
    echo Erreur: Lancez ce script depuis la racine du projet
    pause
    exit /b 1
)

echo Creation des dossiers necessaires...
if not exist "local\ssi" mkdir "local\ssi"
if not exist "global\ssi" mkdir "global\ssi"
if not exist "dev" mkdir "dev"

echo Creation du fichier .htaccess principal...
(
echo Options +Includes +FollowSymLinks
echo AddType text/html .shtml .html
echo AddOutputFilter INCLUDES .shtml .html
echo AddHandler server-parsed .html
echo DirectoryIndex index.html
echo XBitHack on
) > .htaccess

echo Creation du fichier .htaccess pour SSI legacy...
echo SSILegacyExprParser on > "local\ssi\.htaccess"

echo Correction du menu...
(
echo ^<!-- Elements de menu principal personnalise pour ce site --^>
echo ^<li^>^<a href="/local/visuels.html"^>Visuels^</a^>^</li^>
echo ^<li class="dropdown"^>
echo 	^<a href="#" class="disabled"^>Doleances ^&^#9662;^</a^>
echo 	^<ul class="submenu"^>
echo 		^<li^>^<a href="/local/formulaire-doleances.html"^>Formulaire de Doleances^</a^>^</li^>
echo 		^<li^>^<a href="/local/doleances.html"^>Cahier de Doleances^</a^>^</li^>
echo 	^</ul^>
echo ^</li^>
) > "local\ssi\menu_top.shtml"

echo Creation des fichiers SSI manquants...
if not exist "local\ssi\emails.shtml" (
    echo ^<a href="mailto:contact@example.com"^>contact@example.com^</a^> > "local\ssi\emails.shtml"
)

if not exist "local\ssi\gpg.shtml" (
    echo Cle GPG a configurer > "local\ssi\gpg.shtml"
)

echo Creation du serveur Python avec SSI...
if exist "dev\server_template.py" (
    copy "dev\server_template.py" "server.py" >nul
    echo    Serveur Python cree depuis le template
) else (
    echo    Template manquant, creation manuelle...
    echo # -*- coding: utf-8 -*- > server.py
    echo import http.server, socketserver, os, re >> server.py
    echo class SSIHandler(http.server.SimpleHTTPRequestHandler): >> server.py
    echo     def do_GET(self): super().do_GET() >> server.py
    echo PORT = 8000 >> server.py
    echo with socketserver.TCPServer(("localhost", PORT), SSIHandler) as httpd: httpd.serve_forever() >> server.py
)

echo Creation du script de demarrage...
(
echo @echo off
echo chcp 65001 ^>nul
echo Demarrage du serveur de developpement...
echo cd /d "%%~dp0\.."
echo python server.py
echo pause
) > "dev\start.bat"

echo.
echo Configuration terminee !
echo.
echo Pour demarrer le serveur :
echo    dev\start.bat
echo    ou
echo    python server.py
echo.
echo Puis ouvrir : http://localhost:8000
echo.
pause