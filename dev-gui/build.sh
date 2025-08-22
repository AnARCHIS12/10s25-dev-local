#!/bin/bash

echo "🔨 Compilation de l'application 10s25 Dev GUI"
echo "=============================================="

# Installer PyInstaller si nécessaire
if ! command -v pyinstaller &> /dev/null; then
    echo "📦 Installation de PyInstaller..."
    pip install pyinstaller
fi

# Créer l'icône
echo "🎨 Création de l'icône..."
python3 icon.py

# Compilation Linux
echo "🐧 Compilation pour Linux..."
pyinstaller --onefile --windowed --icon=icon.ico --name "10s25-dev-gui" standalone_gui.py

echo "✅ Compilation terminée !"
echo "📁 Exécutable disponible dans : dist/10s25-dev-gui"
echo ""
echo "🚀 Pour lancer : ./dist/10s25-dev-gui"