# restic-backup

Scripts Bash pour automatiser la sauvegarde et la restauration du répertoire home d’un utilisateur Linux vers/depuis un serveur MinIO compatible S3, en utilisant restic.

## Fonctionnalités principales
- Sauvegarde du répertoire home avec exclusions personnalisées
- Restauration du dernier snapshot ou d’un snapshot précis
- Gestion centralisée des exclusions
- Politique de rétention automatique (hourly, daily, weekly, monthly, yearly)
- Sécurisation des secrets via 1Password CLI
- Utilisation simplifiée via Makefile et cron

## Prérequis
- restic installé (`sudo apt install restic`)
- Accès à un serveur MinIO compatible S3
- 1Password CLI (`op`) configuré

## Installation
1. Clonez ou copiez les scripts dans le répertoire de votre choix.
2. Créez un fichier `/etc/restic-backup.env` contenant les variables suivantes :
   ```sh
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   RESTIC_PASSWORD
   MINIO_ENDPOINT
   BUCKET_NAME
   ```
   Les valeurs sont stockées dans 1Password et injectées via `op run`.
3. Vérifiez que le fichier `restic-excludes.txt` contient les motifs à exclure (voir exemple ci-dessous).

## Utilisation avec cron
Ajoutez l’une des lignes suivantes à la crontab de l’utilisateur à sauvegarder :


Sauvegarde toutes les heures :
```sh
5 * * * * op run --env-file=/etc/restic-backup.env -- /home/dd/restic-backup/restic-backup.sh
```


Les secrets sont chargés depuis 1Password et la politique de rétention est appliquée automatiquement.

## Politique de rétention
Après chaque sauvegarde, le script applique automatiquement :
- 6 sauvegardes horaires
- 7 quotidiennes
- 4 hebdomadaires
- 3 mensuelles
- 0 annuelles
Les snapshots plus anciens sont supprimés avec `--prune` pour libérer l’espace.

## Utilisation avec Makefile
Pour faciliter les opérations courantes :

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
- Suppression d’un snapshot par ID :
  ```sh
  make delete SNAPSHOT_ID=<id>
  ```

## Restauration manuelle
Pour restaurer le dernier snapshot dans le dossier `~/restic-restore` :
```sh
/home/dd/restic-backup/restic-restore.sh
```
Pour restaurer dans un autre dossier :
```sh
RESTORE_DIR=/chemin/vers/dossier /home/dd/restic-backup/restic-restore.sh
```
Pour restaurer un snapshot précis :
Modifiez le script et remplacez `latest` par l’ID du snapshot souhaité.

## Exclusions centralisées
Les motifs à exclure sont définis dans le fichier `restic-excludes.txt` à la racine du projet. Les scripts Bash utilisent ce fichier via l’option `--exclude-file` pour garantir la cohérence.

Exemple de contenu :
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
- Pour exclure d’autres fichiers/dossiers, modifiez le fichier `restic-excludes.txt`.
- Le dossier de restauration par défaut est `~/restic-restore` (modifiable via la variable d’environnement `RESTORE_DIR`).
- Les logs peuvent être ajoutés dans les scripts si besoin.

## Sécurité
- Les secrets ne sont jamais stockés en clair sur le disque.
- Les secrets sont lus dynamiquement depuis 1Password via `op run`.
- Les scripts vérifient la présence de toutes les variables d’environnement nécessaires avant de démarrer.

## Dépannage
- Vérifiez que restic est installé et accessible dans le PATH.
- Vérifiez les permissions d’écriture sur `/var/log/` si vous activez les logs.
- Consultez les logs ou la sortie des scripts pour plus d’informations sur les erreurs.

## Auteur
Scripts générés et optimisés avec GitHub Copilot.
