#!/bin/bash

BACKUP_DIR=/backups
DAYS_TO_KEEP=7
BACKUP_FILE="$BACKUP_DIR/motio_backup_$(date +%Y-%m-%d_%H-%M-%S).sql"

pg_dump -h postgres -U "$POSTGRES_USER" -d "$POSTGRES_DB" -F c -b -v -f "$BACKUP_FILE"

find "$BACKUP_DIR" -type f -mtime +$DAYS_TO_KEEP -name '*.sql' -exec rm -f {} \;

echo "Backup completed: $BACKUP_FILE"
