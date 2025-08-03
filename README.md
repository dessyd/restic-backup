
# restic-backup

Scripts Python pour automatiser la sauvegarde et la restauration du répertoire home d’un utilisateur Linux vers/depuis un serveur MinIO compatible S3, en utilisant restic.

## Fonctionnalités
- **restic-backup.py** :
  - Sauvegarde du répertoire home de l’utilisateur courant
  - Exclusion de fichiers et dossiers temporaires ou inutiles
  - Nettoyage automatique des anciens snapshots (conservation des 15 derniers)
  - Vérification et initialisation du repository restic
  - Journalisation détaillée (logs)
  - Protection des paramètres sensibles via variables d’environnement
- **restic-restore.py** :
  - Restauration du dernier snapshot (ou d’un snapshot précis) dans un dossier configurable
  - Liste des snapshots disponibles
  - Journalisation détaillée (logs)

## Prérequis
- Python 3.8+
- restic installé (`sudo apt install restic`)
- Accès à un serveur MinIO compatible S3

## Installation
1. Clonez ou copiez les scripts dans le répertoire de votre choix.
2. Créez un fichier `/etc/restic-backup.env` contenant uniquement les noms des variables à charger :
   ```sh
   MINIO_ACCESS_KEY
   MINIO_SECRET_KEY
   RESTIC_PASSWORD
   MINIO_ENDPOINT
   BUCKET_NAME
   ```
   Les valeurs sont stockées dans 1Password sous la référence :
   `op://Minecraft/Restic/Service Account/<nom_variable>`



## Utilisation avec cron
Ajoutez l’une des lignes suivantes à la crontab de l’utilisateur à sauvegarder :

Sauvegarde tous les jours à 2h du matin :
```sh
0 2 * * * op run --env-file=/etc/restic-backup.env -- /home/dd/restic-backup/restic-backup.sh
```

Sauvegarde toutes les 5 minutes :
```sh
*/5 * * * * op run --env-file=/etc/restic-backup.env -- /home/dd/restic-backup/restic-backup.sh
```

Dans les deux cas, les secrets sont chargés depuis 1Password et la politique de rétention est appliquée automatiquement.


Après chaque sauvegarde, le script applique automatiquement une politique de rétention :
- 6 sauvegardes horaires
- 7 sauvegardes quotidiennes
- 4 hebdomadaires
- 3 mensuelles
- 0 annuelles

Les snapshots plus anciens sont supprimés avec `--prune` pour libérer l’espace.

## Utilisation avec Makefile

Pour faciliter les opérations courantes, vous pouvez utiliser le Makefile fourni :

- Sauvegarde immédiate :
  ```sh
  make backup
  ```
- Restauration dans un dossier spécifique :
  ```sh
  make restore RESTORE_DIR=/chemin/vers/dossier
  ```
- Liste des snapshots disponibles :
  ```sh
  make list
  ```

Ces commandes utilisent les scripts Bash et la configuration centralisée. Pensez à adapter les variables d’environnement et les permissions selon votre contexte.

Pour restaurer le dernier snapshot dans le dossier `~/restic-restore` (en excluant les fichiers/dossiers temporaires et caches) :
```sh
/home/dd/restic-backup/restic-restore.sh
```
Pour restaurer dans un autre dossier :
```sh
RESTORE_DIR=/chemin/vers/dossier /home/dd/restic-backup/restic-restore.sh
```
Pour restaurer un snapshot précis :
Modifiez le script et remplacez `latest` par l’ID du snapshot souhaité.

> **Remarque :** Le script de restauration utilise une liste d’exclusions courantes Linux (caches, téléchargements, fichiers temporaires, etc.) pour éviter de restaurer des données inutiles. Vous pouvez adapter la variable `EXCLUDES` dans `restic-restore.sh` selon vos besoins.
## Exclusions centralisées

Les fichiers et dossiers exclus de la sauvegarde/restauration sont désormais centralisés dans le fichier `restic-excludes.txt` à la racine du projet. Les scripts `restic-backup.sh` et `restic-restore.sh` utilisent ce fichier via l’option `--exclude-file`, ce qui garantit la cohérence des exclusions entre les deux opérations.

Pour modifier les exclusions, éditez simplement le fichier `restic-excludes.txt`. Les changements seront automatiquement pris en compte lors du prochain backup ou restore.

Exemple de contenu :

```txt
*.tmp
*.cache
*/.cache/*
*/.local/share/Trash/*
*/.mozilla/firefox/*/Cache/*
*/.steam/*
*/node_modules/*
*/__pycache__/*
*.pyc
*/.git/*
*/Downloads/*
```

## Personnalisation
- Le répertoire sauvegardé est automatiquement le home de l’utilisateur qui exécute le script.
- Pour exclure d’autres fichiers/dossiers, modifiez la liste `EXCLUDE_PATTERNS` dans le script.
- Les logs sont écrits dans `/var/log/restic-backup-YYYYMMDD.log` ou `/var/log/restic-restore-YYYYMMDD.log` (ou affichés à l’écran si le dossier n’est pas accessible).
- Le dossier de restauration par défaut est `~/restic-restore` (modifiable via la variable d’environnement `RESTORE_DIR`).

## Sécurité
-- Les paramètres sensibles ne sont jamais stockés dans les scripts ni sur le disque local.
-- Les secrets sont lus dynamiquement depuis 1Password via `op run`.
-- Les scripts vérifient la présence de toutes les variables d’environnement nécessaires avant de démarrer.

## Dépannage
- Vérifiez que restic est installé et accessible dans le PATH.
- Vérifiez les permissions d’écriture sur `/var/log/`.
- Consultez les logs pour plus d’informations sur les erreurs.

## Auteur
Scripts générés et optimisés avec GitHub Copilot.
