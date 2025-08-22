# Sites Indignons-nous Bloquons tout pour le 10 septembre 2025 et après

**Projet GitHub** : https://github.com/10s25/site

La doc est [dans le wiki](https://github.com/10s25/site/wiki).

## Développement local

### Option 1 : Interface Graphique (Recommandé)
```bash
# Lancer l'application GUI
cd dev-gui
python3 standalone_gui.py
```
**Fonctionnalités :**
- ✅ Serveur Python intégré avec SSI
- ✅ Gestion Docker complète
- ✅ Ports dynamiques (8000-8003)
- ✅ Interface simple et intuitive

### Option 2 : Serveur Python (ligne de commande)
```bash
# Configuration initiale
./dev/setup.sh

# Démarrage
./dev/start.sh
```
➜ http://localhost:8000

### Option 3 : Docker (Apache + Live reload)
```bash
# Démarrage complet
./dev/docker.sh

# Arrêt
./dev/docker-stop.sh
```
➜ http://localhost:8080 (Apache) | http://localhost:3000 (Live reload) | http://localhost:3001 (BrowserSync)

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
- `dev-gui/` - **Application GUI de développement** *(nouveau)*
- `docker/` - Configuration Docker *(ignoré en prod)*
- `favicon.ico` - Icône du site
- `.htaccess` - Configuration Apache avec sécurité

## Technologies

- HTML + CSS "old school"
- SSI (Server-Side Includes) pour les includes
- PHP pour la génération des groupes
- Python pour le serveur de développement
- Docker pour l'environnement complet
- **Tkinter** pour l'interface graphique
- **PyInstaller** pour la compilation d'exécutables

## Application GUI de Développement

### Compilation d'exécutables

**Linux :**
```bash
cd dev-gui
./build_venv.sh
```

**Windows :**
```cmd
cd dev-gui
build_venv.bat
```

### Fonctionnalités de l'application

- 🖥️ **Interface graphique** simple et intuitive
- 🐍 **Serveur Python intégré** avec support SSI
- 🐳 **Gestion Docker** complète (Apache, Live reload, BrowserSync)
- 🔄 **Ports dynamiques** (8000-8003) si port occupé
- 🎨 **Logo du projet** intégré
- 📱 **Ouverture navigateur** automatique
- 📁 **Sélection de projet** par interface
- 🔒 **Configuration sécurisée** (.htaccess avec headers)

### Distribution

Les exécutables compilés peuvent être distribués sans installation Python :
- **Linux** : `dist/10s25-dev-gui`
- **Windows** : `dist/10s25-dev-gui.exe`

## Ports utilisés

- **8000-8003** : Serveur Python (port dynamique)
- **8080** : Apache (Docker)
- **3000** : Live reload (Docker)
- **3001** : BrowserSync (Docker)
