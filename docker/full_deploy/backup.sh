#!/bin/bash

BACKUP_DIR=/backups
DAYS_TO_KEEP=7
BACKUP_FILE="$BACKUP_DIR/motio_backup_$(date +%Y-%m-%d_%H-%M-%S).sql"

mkdir -p "$BACKUP_DIR"

echo "10.0.1.214:5432:motio:motio_admin:motio_password" > ~/.pgpass

chmod 600 ~/.pgpass

pg_dump -h 10.0.1.214 -U "motio_admin" -d "motio" -F c -b -v -f "$BACKUP_FILE"

find "$BACKUP_DIR" -type f -mtime +$DAYS_TO_KEEP -name '*.sql' -exec rm -f {} \;

echo "Backup completed: $BACKUP_FILE"
