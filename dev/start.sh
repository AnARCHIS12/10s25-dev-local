#!/bin/bash

# Script de démarrage du serveur de développement
# Usage: ./dev/start.sh

echo "🚀 Démarrage du serveur de développement..."
echo "=========================================="

# Aller à la racine du projet
cd "$(dirname "$0")/.."

# Vérifier que server.py existe
if [ ! -f "server.py" ]; then
    echo "❌ Fichier server.py manquant. Lancez d'abord ./dev/setup.sh"
    exit 1
fi

# Vérifier que Python est installé
if ! command -v python3 >/dev/null 2>&1; then
    echo "❌ Python 3 n'est pas installé"
    exit 1
fi

echo "📁 Dossier de travail: $(pwd)"
echo "🐍 Lancement du serveur Python avec support SSI..."
echo ""
echo "🌐 Le site sera accessible sur: http://localhost:8000"
echo "⏹️  Pour arrêter: Ctrl+C"
echo ""

# Lancer le serveur
python3 server.py