#!/bin/bash

# Script de configuration automatique du projet
# Usage: ./dev/setup.sh

set -e

echo "🚀 Configuration automatique du projet site"
echo "================================================"

# Vérifier qu'on est dans le bon dossier
if [ ! -f "index.html" ]; then
    echo "❌ Erreur: Lancez ce script depuis la racine du projet (où se trouve index.html)"
    exit 1
fi

echo "📁 Création des dossiers nécessaires..."
mkdir -p local/ssi
mkdir -p global/ssi
mkdir -p dev

echo "📝 Création du fichier .htaccess principal..."

# Sauvegarder l'ancien .htaccess si il existe
if [ -f ".htaccess" ]; then
    cp .htaccess .htaccess.prod.bak 2>/dev/null || echo "   ⚠️  Impossible de sauvegarder .htaccess (permissions)"
fi

# Créer le nouveau .htaccess (avec gestion des permissions)
{
cat > .htaccess << 'EOF'
Options +Includes +FollowSymLinks
AddType text/html .shtml .html
AddOutputFilter INCLUDES .shtml .html
AddHandler server-parsed .html
DirectoryIndex index.html
XBitHack on
EOF
} 2>/dev/null || {
    echo "   ⚠️  Impossible d'écrire .htaccess (permissions). Création de .htaccess.dev à la place"
    cat > .htaccess.dev << 'EOF'
Options +Includes +FollowSymLinks
AddType text/html .shtml .html
AddOutputFilter INCLUDES .shtml .html
AddHandler server-parsed .html
DirectoryIndex index.html
XBitHack on
EOF
    echo "   💡 Copiez manuellement .htaccess.dev vers .htaccess avec sudo si nécessaire"
}

echo "📝 Création du fichier .htaccess pour SSI legacy..."
cat > local/ssi/.htaccess << 'EOF'
SSILegacyExprParser on
EOF

echo "📝 Correction du menu (suppression des conditions SSI)..."

# Restaurer le menu de dev depuis la sauvegarde si elle existe
if [ -f "local/ssi/menu_top.shtml.dev.bak" ]; then
    cp local/ssi/menu_top.shtml.dev.bak local/ssi/menu_top.shtml
    echo "   🔄 Menu de dev restauré depuis la sauvegarde"
else
    # Créer le menu de dev
    cat > local/ssi/menu_top.shtml << 'EOF'
<!-- Éléments de menu principal personnalisé pour ce site -->
<li><a href="/local/visuels.html">Visuels</a></li>
<li class="dropdown">
	<a href="#" class="disabled">Doléances ▾</a>
	<ul class="submenu">
		<li><a href="/local/formulaire-doleances.html">Formulaire de Doléances</a></li>
		<li><a href="/local/doleances.html">Cahier de Doléances</a></li>
	</ul>
</li>
EOF
fi

echo "📝 Création des fichiers SSI manquants..."
if [ ! -f "local/ssi/emails.shtml" ]; then
    echo '<a href="mailto:contact@example.com">contact@example.com</a>' > local/ssi/emails.shtml
fi

if [ ! -f "local/ssi/gpg.shtml" ]; then
    echo 'Clé GPG à configurer' > local/ssi/gpg.shtml
fi

echo "🐍 Création du serveur Python avec SSI..."
cat > server.py << 'EOF'
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
        pattern = r'<!--#include virtual="([^"]+)" -->'
        
        def replace_include(match):
            include_path = match.group(1)
            try:
                with open(include_path, 'r', encoding='utf-8') as f:
                    return f.read()
            except FileNotFoundError:
                return f'<!-- File not found: {include_path} -->'
        
        # Supprimer les directives SSI non supportées
        content = re.sub(r'<!--#config[^>]*-->', '', content)
        content = re.sub(r'<!--#if[^>]*-->', '', content)
        content = re.sub(r'<!--#endif[^>]*-->', '', content)
        content = re.sub(r'<!--#echo[^>]*-->', '', content)
        
        return re.sub(pattern, replace_include, content)

PORT = 8000
with socketserver.TCPServer(("localhost", PORT), SSIHandler) as httpd:
    print(f"Server running at http://localhost:{PORT}")
    httpd.serve_forever()
EOF

chmod +x server.py

echo "🔧 Génération du fichier groupes.shtml..."
if [ -f "src/update_groups.php" ] && command -v php >/dev/null 2>&1; then
    cd src
    php update_groups.php >/dev/null 2>&1 || echo "⚠️  Erreur lors de la génération des groupes (normal si pas de PHP)"
    cd ..
else
    echo "⚠️  PHP non trouvé, création d'un fichier groupes.shtml basique..."
    cat > global/ssi/groupes.shtml << 'EOF'
<ul class="sidebar-section-1">
    <li>
        <h3 class="font-yellow">Réseaux sociaux</h3>
        <ul class="sidebar-section-2">
            <li>
                <ul>
                    <li class="telegram">
                        <p>Telegram</p>
                        <ul>
                            <li><a href="https://t.me/+B5CJp-RUGpAzMmQ8" target="_blank" rel="me">+B5CJp-RUGpAzMmQ8</a></li>
                        </ul>
                    </li>
                </ul>
            </li>
        </ul>
    </li>
</ul>
EOF
fi

echo "📝 Création du script de démarrage..."
cat > dev/start.sh << 'EOF'
#!/bin/bash
echo "🚀 Démarrage du serveur de développement..."
cd "$(dirname "$0")/.."
python3 server.py
EOF

chmod +x dev/start.sh

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "🎯 Pour démarrer le serveur :"
echo "   ./dev/start.sh"
echo "   ou"
echo "   python3 server.py"
echo ""
echo "🌐 Puis ouvrir : http://localhost:8000"
echo ""
echo "📋 Fichiers créés/modifiés :"
echo "   - .htaccess (SSI activés)"
echo "   - local/ssi/.htaccess (SSI legacy)"
echo "   - local/ssi/menu_top.shtml (corrigé)"
echo "   - server.py (serveur Python avec SSI)"
echo "   - dev/start.sh (script de démarrage)"
echo ""