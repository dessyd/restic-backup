# Makefile pour restic-backup

BACKUP_SCRIPT=./restic-backup.sh
RESTORE_SCRIPT=./restic-restore.sh
RESTORE_DIR?=$(HOME)/restic-restore

.PHONY: backup restore list
.PHONY: backup restore list delete

backup:
	@echo "[restic] Sauvegarde immédiate du home utilisateur..."
	$(BACKUP_SCRIPT)

restore:
	@echo "[restic] Restauration dans le dossier $(RESTORE_DIR)..."
	RESTORE_DIR=$(RESTORE_DIR) $(RESTORE_SCRIPT)

list:
	@echo "[restic] Liste des snapshots disponibles..."
	@bash -c 'source /etc/restic-backup.env && \
AWS_ACCESS_KEY_ID=$$(op read "$$AWS_ACCESS_KEY_ID") \
AWS_SECRET_ACCESS_KEY=$$(op read "$$AWS_SECRET_ACCESS_KEY") \
RESTIC_PASSWORD=$$(op read "$$RESTIC_PASSWORD") \
RESTIC_REPOSITORY="s3:http://$$MINIO_ENDPOINT/$$BUCKET_NAME" \
restic snapshots'
delete:
	@if [ -z "$(SNAPSHOT_ID)" ]; then \
	  echo "Usage: make delete SNAPSHOT_ID=<id>"; \
	  exit 1; \
	fi
	@echo "[restic] Suppression du snapshot $(SNAPSHOT_ID)..."
	@bash -c 'source /etc/restic-backup.env && \
	AWS_ACCESS_KEY_ID=$$(op read "$$AWS_ACCESS_KEY_ID") \
	AWS_SECRET_ACCESS_KEY=$$(op read "$$AWS_SECRET_ACCESS_KEY") \
	RESTIC_PASSWORD=$$(op read "$$RESTIC_PASSWORD") \
	RESTIC_REPOSITORY="s3:http://$$MINIO_ENDPOINT/$$BUCKET_NAME" \
	restic forget $(SNAPSHOT_ID) --prune'
