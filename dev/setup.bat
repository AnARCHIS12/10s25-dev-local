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
echo # -*- coding: utf-8 -*- > server.py
echo #!/usr/bin/env python3 >> server.py
echo import http.server >> server.py
echo import socketserver >> server.py
echo import os >> server.py
echo import re >> server.py
echo. >> server.py
echo class SSIHandler(http.server.SimpleHTTPRequestHandler): >> server.py
echo     def do_GET(self): >> server.py
echo         if self.path.endswith('.html') or self.path == '/': >> server.py
echo             try: >> server.py
echo                 if self.path == '/': >> server.py
echo                     filepath = 'index.html' >> server.py
echo                 else: >> server.py
echo                     filepath = self.path.lstrip('/') >> server.py
echo. >> server.py
echo                 with open(filepath, 'r', encoding='utf-8') as f: >> server.py
echo                     content = f.read() >> server.py
echo. >> server.py
echo                 content = self.process_ssi(content) >> server.py
echo. >> server.py
echo                 self.send_response(200) >> server.py
echo                 self.send_header('Content-type', 'text/html; charset=utf-8') >> server.py
echo                 self.end_headers() >> server.py
echo                 self.wfile.write(content.encode('utf-8')) >> server.py
echo             except FileNotFoundError: >> server.py
echo                 super().do_GET() >> server.py
echo         else: >> server.py
echo             super().do_GET() >> server.py
echo. >> server.py
echo     def process_ssi(self, content): >> server.py
echo         pattern = r'<!--#include virtual="([^"]+)" -->' >> server.py
echo. >> server.py
echo         def replace_include(match): >> server.py
echo             include_path = match.group(1) >> server.py
echo             try: >> server.py
echo                 with open(include_path, 'r', encoding='utf-8') as f: >> server.py
echo                     return f.read() >> server.py
echo             except FileNotFoundError: >> server.py
echo                 return f'<!-- File not found: {include_path} -->' >> server.py
echo. >> server.py
echo         # Supprimer les directives SSI non supportees >> server.py
echo         content = re.sub(r'<!--#config[^>]*-->', '', content) >> server.py
echo         content = re.sub(r'<!--#if[^>]*-->', '', content) >> server.py
echo         content = re.sub(r'<!--#endif[^>]*-->', '', content) >> server.py
echo         content = re.sub(r'<!--#echo[^>]*-->', '', content) >> server.py
echo. >> server.py
echo         return re.sub(pattern, replace_include, content) >> server.py
echo. >> server.py
echo PORT = 8000 >> server.py
echo with socketserver.TCPServer(("localhost", PORT), SSIHandler) as httpd: >> server.py
echo     print(f"Server running at http://localhost:{PORT}") >> server.py
echo     httpd.serve_forever() >> server.py

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