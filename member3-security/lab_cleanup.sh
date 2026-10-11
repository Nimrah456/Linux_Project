#!/bin/bash
# lab_cleanup.sh - Member 3
# Deletes files older than 30 days in /data/shared*

LOG=/var/log/lab_cleanup.log

echo "[$(date)] Cleanup started" >> "$LOG"
find /data/shared* -type f -mtime +30 -print -delete >> "$LOG" 2>&1
echo "[$(date)] Cleanup finished" >> "$LOG"

echo "Cleanup complete. See $LOG"
