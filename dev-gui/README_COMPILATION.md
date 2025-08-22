# Compilation Multi-Plateforme

## Linux

### Option 1 : Compilation simple
```bash
./build_venv.sh
```

### Option 2 : Compilation manuelle
```bash
python3 -m venv venv
source venv/bin/activate
pip install pyinstaller
pyinstaller --onefile --windowed --icon=../favicon.ico --name "10s25-dev-gui" standalone_gui.py
```

## Windows

### Option 1 : Script automatique
```cmd
build_venv.bat
```

### Option 2 : Compilation manuelle
```cmd
python -m venv venv
venv\Scripts\activate
pip install pyinstaller
pyinstaller --onefile --windowed --icon=..\favicon.ico --name "10s25-dev-gui" standalone_gui.py
```

## Résultat

- **Linux** : `dist/10s25-dev-gui`
- **Windows** : `dist/10s25-dev-gui.exe`

## Distribution

Les exécutables peuvent être distribués sans installation Python sur les machines cibles.

## Fonctionnalités

✅ Serveur Python intégré avec SSI  
✅ Gestion Docker complète  
✅ Interface graphique simple  
✅ Logo et favicon du projet  
✅ Ports dynamiques  
✅ Compilation cross-platform