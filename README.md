# Outils de développement local - Sites Indignons-nous Bloquons tout

**Projet GitHub** : https://github.com/10s25/site

La documentation complète est disponible [dans le wiki](https://github.com/10s25/site/wiki).

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

Pour utiliser les scripts sur Windows, vous devez installer bash :

1. **Git Bash** (recommandé) :
   - Téléchargez et installez [Git for Windows](https://git-scm.com/download/win)
   - Git Bash sera disponible dans le menu Démarrer
   - Ouvrez Git Bash et naviguez vers votre projet

2. **WSL (Windows Subsystem for Linux)** :
   ```powershell
   # Dans PowerShell en tant qu'administrateur
   wsl --install
   # Redémarrez votre ordinateur
   # Puis ouvrez Ubuntu depuis le menu Démarrer
   ```

3. **MSYS2** :
   - Téléchargez [MSYS2](https://www.msys2.org/)
   - Suivez les instructions d'installation
   - Utilisez le terminal MSYS2

Une fois bash installé, utilisez les mêmes commandes :
```bash
# Configuration initiale
./dev/setup.sh

# Démarrage
./dev/start.sh
```

➜ http://localhost:8000

### Option 2 : Docker (Apache + Live reload)

**Toutes les plateformes (avec bash installé) :**
```bash
# Démarrage complet
./dev/docker.sh

# Arrêt
./dev/docker-stop.sh
```

➜ **Accès aux services :**
- http://localhost:8080 (Apache)
- http://localhost:3000 (Live reload)
- http://localhost:3001 (BrowserSync)

### Préparation production

**Toutes les plateformes (avec bash installé) :**
```bash
# Donner les permissions d'exécution (première fois seulement)
chmod +x dev/prod.sh

# Préparer pour la production
./dev/prod.sh
```

## Structure du projet

```
├── index.html              # Page d'accueil
├── global/                 # Ressources partagées (CSS, JS, SSI)
├── local/                  # Personnalisations locales
├── src/                    # Scripts PHP de génération
├── dev/                    # Outils de développement (ignoré en prod)
│   └── *.sh               # Scripts bash
├── docker/                 # Configuration Docker (ignoré en prod)
├── favicon.ico            # Icône du site
└── .htaccess              # Configuration Apache avec sécurité
```

## Technologies

- **HTML + CSS** "old school"
- **SSI** (Server-Side Includes) pour les includes
- **PHP** pour la génération des groupes
- **Python** pour le serveur de développement
- **Docker** pour l'environnement complet

## Ports utilisés

| Port | Service | Environnement |
|------|---------|---------------|
| 8000-8003 | Serveur Python | Développement (port dynamique) |
| 8080 | Apache | Docker |
| 3000 | Live reload | Docker |
| 3001 | BrowserSync | Docker |

## Prérequis

### Pour tous les environnements
- **Git** (pour cloner le projet)

### Option 1 - Serveur Python
- **Python 3.x** installé sur votre système

### Option 2 - Docker
- **Docker** et **Docker Compose** installés

### Windows - Installation de bash (requis)
Pour utiliser ce projet sur Windows, vous devez installer bash. Choisissez une des options :

1. **Git Bash** ⭐ (le plus simple)
2. **WSL** (Windows Subsystem for Linux)
3. **MSYS2**

Voir les instructions détaillées dans la section "Développement local" ci-dessus.

