#!/bin/bash

# Script de préparation pour la production
# Remet les fichiers SSI dans leur état original pour Apache
# Usage: ./dev/prod.sh

set -e

echo "🏭 Préparation pour la production..."
echo "===================================="

# Vérifier qu'on est dans le bon dossier
if [ ! -f "index.html" ]; then
    echo "❌ Erreur: Lancez ce script depuis la racine du projet (où se trouve index.html)"
    exit 1
fi

echo "🔄 Restauration du menu avec conditions SSI pour Apache..."
cat > local/ssi/menu_top.shtml << 'EOF'
<!-- Éléments de menu principal personnalisé pour ce site  --><!--#config errmsg="" -->
<li<!--#if expr="$REQUEST_URI = '/local/visuels.html'" --> class="selected"<!--#endif -->><a href="/local/visuels.html">Visuels</a></li>
<li class="dropdown<!--#if expr="$REQUEST_URI = /doleances/" --> selected<!--#endif -->">
	<a href="#" class="disabled">Doléances ▾</a>
	<ul class="submenu">
		<li<!--#if expr="$REQUEST_URI = '/local/formulaire-doleances.html'" --> class="selected"<!--#endif -->><a href="/local/formulaire-doleances.html">Formulaire de Doléances</a></li>
		<li<!--#if expr="$REQUEST_URI = '/local/doleances.html'" --> class="selected"<!--#endif -->><a href="/local/doleances.html">Cahier de Doléances</a></li>
	</ul>
</li>
EOF

echo "🗑️  Suppression des fichiers de développement..."
[ -f "server.py" ] && rm server.py && echo "   - server.py supprimé"

echo "📝 Mise à jour du .htaccess pour Apache de production..."
cat > .htaccess << 'EOF'
Options +Includes +FollowSymLinks
AddType text/html .shtml .html
AddOutputFilter INCLUDES .shtml .html
AddHandler server-parsed .html
DirectoryIndex index.html
XBitHack on

# Configuration pour la production
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
</IfModule>

# Cache pour les ressources statiques
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
</IfModule>
EOF

echo "🔧 Régénération finale des groupes..."
if [ -f "src/update_groups.php" ] && command -v php >/dev/null 2>&1; then
    cd src
    php update_groups.php >/dev/null 2>&1 && echo "   ✅ Groupes régénérés"
    cd ..
else
    echo "   ⚠️  PHP non disponible, groupes non régénérés"
fi

echo "📋 Création du fichier de déploiement..."
cat > DEPLOIEMENT.md << 'EOF'
# Déploiement en production

## Prérequis serveur
- Apache avec mod_include activé
- PHP (optionnel, pour la génération des groupes)

## Installation
1. Copier tous les fichiers sur le serveur
2. Vérifier que mod_include est activé :
   ```bash
   a2enmod include
   systemctl reload apache2
   ```

## Structure déployée
- ✅ Fichiers .htaccess configurés pour Apache
- ✅ Menu avec conditions SSI pour sélection active
- ✅ Configuration de sécurité et cache
- ✅ Groupes générés (si PHP disponible)

## Test
- Vérifier que les includes SSI fonctionnent
- Vérifier que le menu s'affiche correctement
- Vérifier que la sidebar contient tous les groupes

## Maintenance
Pour mettre à jour les groupes :
```bash
cd src/
php update_groups.php
```
EOF

echo ""
echo "✅ Préparation production terminée !"
echo ""
echo "📦 Le projet est prêt pour le déploiement Apache"
echo ""
echo "🔄 Changements effectués :"
echo "   - Menu restauré avec conditions SSI"
echo "   - server.py supprimé"
echo "   - .htaccess optimisé pour la production"
echo "   - Groupes régénérés"
echo "   - Documentation de déploiement créée"
echo ""
echo "📋 Voir DEPLOIEMENT.md pour les instructions"
echo ""
echo "🔙 Pour revenir en mode dev : ./dev/setup.sh"
echo ""