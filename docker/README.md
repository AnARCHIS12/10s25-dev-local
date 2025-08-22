# Environnement Docker

## Démarrage rapide

```bash
# Démarrer les conteneurs
./dev/docker.sh

# Arrêter les conteneurs
./dev/docker-stop.sh
```

## Services disponibles

- **Apache (production)** : http://localhost:8080
  - Serveur Apache avec SSI activés
  - Configuration de production
  
- **Live reload (développement)** : http://localhost:3000
  - Rechargement automatique des modifications
  - Proxy vers Apache
  
- **BrowserSync panel** : http://localhost:3001
  - Interface de contrôle BrowserSync
  - Logs et statistiques

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Node.js       │    │     Apache      │
│  (Live Reload)  │◄──►│   (Production)  │
│   Port 3000     │    │    Port 8080    │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
                   │
            ┌─────────────┐
            │   Projet    │
            │  (Volume)   │
            └─────────────┘
```

## Commandes Docker

```bash
# Voir les logs
docker compose logs -f

# Redémarrer un service
docker compose restart apache

# Reconstruire les images
docker compose up --build

# Nettoyer
docker compose down --volumes
```