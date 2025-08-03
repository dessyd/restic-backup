#!/bin/bash

# Charge les variables du fichier de config
source /etc/restic-backup.env

# Récupère les secrets via op (1Password CLI)
export AWS_ACCESS_KEY_ID=$(op read "$AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(op read "$AWS_SECRET_ACCESS_KEY")
export RESTIC_PASSWORD=$(op read "$RESTIC_PASSWORD")

# Définit le repository restic
export RESTIC_REPOSITORY="s3:http://$MINIO_ENDPOINT/$BUCKET_NAME"


# Sauvegarde le répertoire home de l'utilisateur courant avec exclusions centralisées
restic backup "$HOME" --exclude-file="$(dirname "$0")/restic-excludes.txt"

# Nettoyage des anciens snapshots selon la politique demandée
restic forget --keep-hourly 6 --keep-daily 7 --keep-weekly 4 --keep-monthly 3 --keep-yearly 0 --prune
