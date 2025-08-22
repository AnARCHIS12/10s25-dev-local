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
if exist "server.py" (
    echo    server.py existe deja, pas de modification
) else if exist "dev\server_template.py" (
    copy "dev\server_template.py" "server.py" >nul
    echo    Serveur Python cree depuis le template
) else (
    echo    Creation du serveur Python avec PowerShell...
    powershell -Command "$content = @'
# -*- coding: utf-8 -*-
#!/usr/bin/env python3
import http.server
import socketserver
import os
import re

class SSIHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.endswith('.html') or self.path == '/':
            try:
                if self.path == '/':
                    filepath = 'index.html'
                else:
                    filepath = self.path.lstrip('/')
                
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                content = self.process_ssi(content)
                
                self.send_response(200)
                self.send_header('Content-type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(content.encode('utf-8'))
            except FileNotFoundError:
                super().do_GET()
        else:
            super().do_GET()
    
    def process_ssi(self, content):
        pattern = r'<!--#include virtual=\"([^\"]+)\" -->'
        
        def replace_include(match):
            include_path = match.group(1)
            try:
                with open(include_path, 'r', encoding='utf-8') as f:
                    return f.read()
            except FileNotFoundError:
                return f'<!-- File not found: {include_path} -->'
        
        content = re.sub(r'<!--#config[^>]*-->', '', content)
        content = re.sub(r'<!--#if[^>]*-->', '', content)
        content = re.sub(r'<!--#endif[^>]*-->', '', content)
        content = re.sub(r'<!--#echo[^>]*-->', '', content)
        
        return re.sub(pattern, replace_include, content)

PORT = 8000
with socketserver.TCPServer((\"localhost\", PORT), SSIHandler) as httpd:
    print(f\"Server running at http://localhost:{PORT}\")
    httpd.serve_forever()
'@; $content | Out-File -FilePath 'server.py' -Encoding UTF8"
    echo    Serveur Python cree avec PowerShell
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