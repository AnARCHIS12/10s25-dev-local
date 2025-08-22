#!/bin/bash
# Script de lancement pour Linux

cd "$(dirname "$0")"
export FONTCONFIG_FILE=/dev/null
export DISPLAY=:0
python3 dev_gui.py >/dev/null 2>&1 &
echo "Interface graphique lancée en arrière-plan"