#!/bin/bash

# Charge les variables du fichier de config
source /etc/restic-backup.env

# Récupère les secrets via op (1Password CLI)
export AWS_ACCESS_KEY_ID=$(op read "$AWS_ACCESS_KEY_ID")
export AWS_SECRET_ACCESS_KEY=$(op read "$AWS_SECRET_ACCESS_KEY")
export RESTIC_PASSWORD=$(op read "$RESTIC_PASSWORD")

# Définit le repository restic
export RESTIC_REPOSITORY="s3:http://$MINIO_ENDPOINT/$BUCKET_NAME"

# Dossier de restauration (par défaut ~/restic-restore, modifiable via RESTORE_DIR)
RESTORE_DIR="${RESTORE_DIR:-$HOME/restic-restore}"


# Restaure le dernier snapshot dans le dossier cible avec exclusions centralisées
restic restore latest --target "$RESTORE_DIR" --exclude-file="$(dirname "$0")/restic-excludes.txt"
