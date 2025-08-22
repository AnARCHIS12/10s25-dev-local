@echo off
echo 🔨 Compilation de l'application 10s25 Dev GUI
echo ==============================================

REM Créer environnement virtuel
echo 📦 Création de l'environnement virtuel...
python -m venv venv
call venv\Scripts\activate

REM Installer dépendances
echo 📦 Installation des dépendances...
pip install pyinstaller

REM Copier le favicon du projet
if exist "..\favicon.ico" (
    copy "..\favicon.ico" .
    echo 🎨 Favicon du projet copié
)

REM Compilation Windows
echo 🪟 Compilation pour Windows...
if exist "favicon.ico" (
    pyinstaller --onefile --windowed --icon=favicon.ico --add-data "favicon.ico;." --name "10s25-dev-gui" standalone_gui.py
) else (
    pyinstaller --onefile --windowed --name "10s25-dev-gui" standalone_gui.py
)

echo ✅ Compilation terminée !
echo 📁 Exécutable disponible dans : dist\10s25-dev-gui.exe
echo.
echo 🚀 Pour lancer : dist\10s25-dev-gui.exe
pause