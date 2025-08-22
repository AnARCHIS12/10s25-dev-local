# Sites Indignons-nous pour le 10 septembre 2025 et après

**Projet GitHub** : https://github.com/10s25/site

La doc est [dans le wiki](https://github.com/10s25/site/wiki).

## Développement local

### Option 1 : Serveur Python (simple)
```bash
# Configuration initiale
./dev/setup.sh

# Démarrage
./dev/start.sh
```
➜ http://localhost:8000

### Option 2 : Docker (Apache + Live reload)
```bash
# Démarrage complet
./dev/docker.sh

# Arrêt
./dev/docker-stop.sh
```
➜ http://localhost:8080 (Apache) | http://localhost:3000 (Live reload)

### Préparation production
```bash
./dev/prod.sh
```

## Structure du projet

- `index.html` - Page d'accueil
- `global/` - Ressources partagées (CSS, JS, SSI)
- `local/` - Personnalisations locales
- `src/` - Scripts PHP de génération
- `dev/` - Outils de développement *(ignoré en prod)*
- `docker/` - Configuration Docker *(ignoré en prod)*

## Technologies

- HTML + CSS "old school"
- SSI (Server-Side Includes) pour les includes
- PHP pour la génération des groupes
- Python pour le serveur de développement
- Docker pour l'environnement complet