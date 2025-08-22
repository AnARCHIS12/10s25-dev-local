# Interface Graphique de Développement

Application GUI simple pour gérer le développement local du projet 10s25.

## Utilisation

### Linux/macOS
```bash
python3 standalone_gui.py
```

### Windows
```cmd
python standalone_gui.py
```

## Fonctionnalités

- **Sélection de projet** : Choisir le dossier du projet à développer
- **Serveur Python intégré** : Serveur HTTP avec support SSI
- **Ports dynamiques** : Essaie automatiquement les ports 8000-8003
- **Gestion Docker** : Démarrage/arrêt de l'environnement complet
- **Ouverture navigateur** : Accès direct aux différents services
- **Logo du projet** : Interface avec l'identité visuelle
- **Favicon intégré** : Icône du projet dans l'application

## Prérequis

- Python 3.x
- Tkinter (inclus avec Python)
- Docker (pour les fonctionnalités Docker)

## Interface

L'interface propose 3 sections :
1. **Sélection du projet** - Choisir le dossier de travail
2. **Serveur Python Simple** - Pour le développement rapide
3. **Environnement Docker** - Apache, Live reload, BrowserSync

## Ports utilisés

- **8000-8003** : Serveur Python (port automatique)
- **8080** : Apache (Docker)
- **3000** : Live reload (Docker)
- **3001** : BrowserSync (Docker)

