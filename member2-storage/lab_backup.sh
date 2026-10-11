#!/bin/bash
# Member 2: Storage Management (Backup Automation)

BACKUP_DIR="/backup"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE_NAME="lab_data_backup_$TIMESTAMP.tar.gz"

echo "Creating backup directory..."
mkdir -p $BACKUP_DIR

echo "Archiving shared folders..."
tar -czvf $BACKUP_DIR/$ARCHIVE_NAME /data/shared*

echo "Backup completed: $BACKUP_DIR/$ARCHIVE_NAME"
ls -lh $BACKUP_DIR
