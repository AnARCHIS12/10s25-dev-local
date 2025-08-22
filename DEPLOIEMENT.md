# Déploiement en production

## Prérequis serveur
- Apache avec mod_include activé
- PHP (optionnel, pour la génération des groupes)

## Installation
1. Copier tous les fichiers sur le serveur
2. Vérifier que mod_include est activé :
   ```bash
   a2enmod include
   systemctl reload apache2
   ```

## Structure déployée
- ✅ Fichiers .htaccess configurés pour Apache
- ✅ Menu avec conditions SSI pour sélection active
- ✅ Configuration de sécurité et cache
- ✅ Groupes générés (si PHP disponible)

## Test
- Vérifier que les includes SSI fonctionnent
- Vérifier que le menu s'affiche correctement
- Vérifier que la sidebar contient tous les groupes

## Maintenance
Pour mettre à jour les groupes :
```bash
cd src/
php update_groups.php
```
