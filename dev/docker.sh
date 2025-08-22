#!/bin/bash

# Script de démarrage Docker pour le développement local
# Usage: ./dev/docker.sh

echo "🐳 Démarrage de l'environnement Docker..."
echo "========================================"

# Aller à la racine du projet
cd "$(dirname "$0")/.."

# Vérifier que Docker est installé
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker n'est pas installé"
    echo "   Installez Docker : https://docs.docker.com/get-docker/"
    exit 1
fi

# Vérifier que Docker Compose est disponible
if ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose n'est pas disponible"
    exit 1
fi

# Vérifier que les fichiers Docker existent
if [ ! -f "docker/Dockerfile" ] || [ ! -f "docker/compose.yaml" ]; then
    echo "❌ Fichiers Docker manquants dans le dossier docker/"
    exit 1
fi

echo "📁 Dossier de travail: $(pwd)"
echo "🔧 Préparation pour la production Docker..."

# Préparer pour la production (SSI Apache complets)
if [ -f "dev/prod.sh" ]; then
    echo "   Exécution de ./dev/prod.sh..."
    ./dev/prod.sh
fi

echo ""
echo "🐳 Construction et démarrage des conteneurs..."
cd docker

# Arrêter les conteneurs existants
docker compose down 2>/dev/null || true

# Construire et démarrer
docker compose up --build -d

echo ""
echo "✅ Conteneurs démarrés !"
echo ""
echo "🌐 Accès au site :"
echo "   - Apache (production) : http://localhost:8080"
echo "   - Live reload (dev)   : http://localhost:3000"
echo "   - BrowserSync panel   : http://localhost:3001"
echo ""
echo "📋 Commandes utiles :"
echo "   docker compose logs -f     # Voir les logs"
echo "   docker compose down        # Arrêter les conteneurs"
echo "   docker compose restart     # Redémarrer"
echo ""
echo "⏹️  Pour arrêter : ./dev/docker-stop.sh"
echo ""