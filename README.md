# Dev local outils pour le sites Indignons-nous Bloquons tout pour le 10 septembre 2025 et après

**Projet GitHub** : https://github.com/10s25/site

La doc est [dans le wiki](https://github.com/10s25/site/wiki).

## Développement local

### Option 1 : Serveur Python (ligne de commande)

**Linux/macOS :**
```bash
# Configuration initiale
./dev/setup.sh

# Démarrage
./dev/start.sh
```

**Windows :**
```cmd
REM Configuration initiale
dev\setup.bat

REM Démarrage
dev\start.bat
```
➜ http://localhost:8000

### Option 2 : Docker (Apache + Live reload)

**Linux/macOS :**
```bash
# Démarrage complet
./dev/docker.sh

# Arrêt
./dev/docker-stop.sh
```

**Windows :**
```cmd
REM Démarrage complet
dev\docker.bat

REM Arrêt
dev\docker-stop.bat
```
➜ http://localhost:8080 (Apache) | http://localhost:3000 (Live reload) | http://localhost:3001 (BrowserSync)

### Préparation production

**Linux/macOS :**
```bash
./dev/prod.sh
```

**Windows :**
```cmd
dev\prod.bat
```

## Structure du projet

- `index.html` - Page d'accueil
- `global/` - Ressources partagées (CSS, JS, SSI)
- `local/` - Personnalisations locales
- `src/` - Scripts PHP de génération
- `dev/` - Outils de développement *(ignoré en prod)*
  - Scripts Linux/macOS : `.sh`
  - Scripts Windows : `.bat`

- `docker/` - Configuration Docker *(ignoré en prod)*
- `favicon.ico` - Icône du site
- `.htaccess` - Configuration Apache avec sécurité

## Technologies

- HTML + CSS "old school"
- SSI (Server-Side Includes) pour les includes
- PHP pour la génération des groupes
- Python pour le serveur de développement
- Docker pour l'environnement complet




## Ports utilisés

- **8000-8003** : Serveur Python (port dynamique)
- **8080** : Apache (Docker)
- **3000** : Live reload (Docker)
- **3001** : BrowserSync (Docker)
