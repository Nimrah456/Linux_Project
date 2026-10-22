#!/usr/bin/env bash

set -Eeuo pipefail

BACKUP_DIR="/backup"

VALID_NAME='^lab_data_backup_[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}\.tar\.gz$'

case "${1:-}" in

    list)
        if [[ ! -d "$BACKUP_DIR" ]]; then
            echo "ERROR: Backup directory does not exist." >&2
            exit 1
        fi

        shopt -s nullglob

        for archive in "$BACKUP_DIR"/lab_data_backup_*.tar.gz; do
            [[ -f "$archive" && ! -L "$archive" ]] || continue

            stat -c '%n|%s|%y' -- "$archive"
        done
        ;;

    inspect)
        filename="${2:-}"

        if [[ ! "$filename" =~ $VALID_NAME ]]; then
            echo "ERROR: Invalid backup filename." >&2
            exit 2
        fi

        archive="$BACKUP_DIR/$filename"

        if [[ ! -f "$archive" || -L "$archive" ]]; then
            echo "ERROR: Backup archive not found." >&2
            exit 1
        fi

        tar -tzf "$archive" |
            awk 'NR <= 100 {print}
                 END {
                     printf "\nTotal archive entries: %d\n", NR
                 }'
        ;;

    create)
        # Require the expected shared folders to be mounted.
        sources=()

        for directory in \
            /data/shared1 \
            /data/shared2 \
            /data/shared3
        do
            if [[ ! -d "$directory" ]]; then
                echo "ERROR: Missing directory: $directory" >&2
                exit 1
            fi

            if ! mountpoint -q "$directory"; then
                echo "ERROR: $directory is not mounted. Backup cancelled." >&2
                exit 1
            fi

            sources+=("${directory#/}")
        done

        mkdir -p "$BACKUP_DIR"

        # Protect newly created archives from other local users.
        umask 077

        timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
        archive="$BACKUP_DIR/lab_data_backup_${timestamp}.tar.gz"

        # Avoid accidentally overwriting a backup created in the same second.
        while [[ -e "$archive" ]]; do
            sleep 1
            timestamp="$(date +"%Y-%m-%d_%H-%M-%S")"
            archive="$BACKUP_DIR/lab_data_backup_${timestamp}.tar.gz"
        done

        echo "Creating backup..."

        tar -czf "$archive" -C / "${sources[@]}"

        # Verify the compressed archive.
        gzip -t "$archive"

        chmod 600 "$archive"

        echo "BACKUP_CREATED=$archive"
        stat -c 'Archive size: %s bytes' -- "$archive"

        echo "Backup created and integrity check passed."
        ;;

    *)
        echo "Usage: $0 {list|create|inspect <filename>}" >&2
        exit 2
        ;;

esac
