#!/bin/bash

echo "🔨 Compilation de l'application 10s25 Dev GUI"
echo "=============================================="

# Créer environnement virtuel
echo "📦 Création de l'environnement virtuel..."
python3 -m venv venv
source venv/bin/activate

# Installer dépendances
echo "📦 Installation des dépendances..."
pip install pyinstaller pillow

# Créer l'icône
echo "🎨 Création de l'icône..."
python3 icon.py

# Copier le favicon du projet
if [ -f "../favicon.ico" ]; then
    cp ../favicon.ico .
    echo "🎨 Favicon du projet copié"
fi

# Compilation Linux
echo "🐧 Compilation pour Linux..."
if [ -f "favicon.ico" ]; then
    pyinstaller --onefile --windowed --icon=favicon.ico --add-data "favicon.ico:." --name "10s25-dev-gui" standalone_gui.py
else
    pyinstaller --onefile --windowed --name "10s25-dev-gui" standalone_gui.py
fi

echo "✅ Compilation terminée !"
echo "📁 Exécutable disponible dans : dist/10s25-dev-gui"
echo ""
echo "🚀 Pour lancer : ./dist/10s25-dev-gui"