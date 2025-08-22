#!/bin/bash

# Script d'arrêt des conteneurs Docker
# Usage: ./dev/docker-stop.sh

echo "🛑 Arrêt des conteneurs Docker..."
echo "================================="

# Aller au dossier docker
cd "$(dirname "$0")/../docker"

# Arrêter et supprimer les conteneurs
docker compose down

echo ""
echo "✅ Conteneurs arrêtés !"
echo ""
echo "🔄 Pour redémarrer : ./dev/docker.sh"
echo ""