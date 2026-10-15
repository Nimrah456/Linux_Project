#!/bin/bash
# OWNER: Member 2 - Storage & Backup Administrator
# Disk/partition/LVM inspection, backup, restore, storage validation.

menu_storage() {
    echo "--- Storage and Backup ---"
    echo "1. Create Backup"
    echo "2. Restore Backup"
    echo "3. Verify Backup Integrity"
    echo "4. Disk, Partition and File-System Overview"
    echo "5. LVM Overview (PV / VG / LV)"
    echo "6. Storage Allocation Check (disk usage of lab data)"

    read -r -p "Choose: " st_opt

    case "$st_opt" in
        1)
            local timestamp backup_file
            timestamp="$(date +'%Y%m%d_%H%M%S')"
            backup_file="backups/lab_backup_$timestamp.tar.gz"

            if tar -czf "$backup_file" shared_labs/ config/; then
                echo "[OK] Backup created: $backup_file"
                echo "$(date): Backup created: $backup_file" >> logs/activity.log
            else
                rm -f "$backup_file"
                echo "[FAIL] Backup creation failed."
                return 1
            fi
            ;;

        2)
            local b_file backup_path confirmation

            if ! compgen -G "backups/*.tar.gz" >/dev/null; then
                echo "No backups found."
                return 0
            fi

            ls -lh backups/*.tar.gz
            read -r -p "Enter backup filename: " b_file

            if [[ -z "$b_file" || "$b_file" == */* ||
                  "$b_file" == *..* || "$b_file" != *.tar.gz ]]; then
                echo "[FAIL] Invalid backup filename."
                return 1
            fi

            backup_path="backups/$b_file"

            if [[ ! -f "$backup_path" ]] || ! tar -tzf "$backup_path" >/dev/null; then
                echo "[FAIL] Backup not found or invalid."
                return 1
            fi

            read -r -p "Type RESTORE to extract into the project directory: " confirmation
            if [[ "$confirmation" != "RESTORE" ]]; then
                echo "Restore cancelled."
                return 0
            fi

            if tar -xzf "$backup_path" -C .; then
                echo "[OK] Backup restored."
                echo "$(date): Backup restored: $b_file" >> logs/activity.log
            else
                echo "[FAIL] Restore failed."
                return 1
            fi
            ;;

        3)
            local f ok=0 bad=0
            if ! compgen -G "backups/*.tar.gz" >/dev/null; then
                echo "No backups found."; return 0
            fi
            for f in backups/*.tar.gz; do
                if tar -tzf "$f" >/dev/null 2>&1; then
                    echo "[OK]   $f"; ok=$((ok + 1))
                else
                    echo "[BAD]  $f"; bad=$((bad + 1))
                fi
            done
            echo "Valid: $ok  Corrupt: $bad"
            ;;

        4)
            echo "--- Block Devices ---";  lsblk -f 2>/dev/null || echo "lsblk not available"
            echo "--- Mounted FS ---";     df -hT -x tmpfs -x devtmpfs 2>/dev/null
            echo "--- fstab ---";          grep -v '^#' /etc/fstab 2>/dev/null | grep -v '^$'
            ;;

        5)
            if command -v pvs >/dev/null 2>&1; then
                echo "--- Physical Volumes ---"; pvs
                echo "--- Volume Groups ---";    vgs
                echo "--- Logical Volumes ---";  lvs
            else
                echo "LVM tools not installed (apt-get install lvm2). Read-only view only."
            fi
            ;;

        6)
            local use
            echo "--- Lab data usage ---"
            du -sh shared_labs config backups 2>/dev/null
            echo "--- Root file-system ---"
            df -h / | tail -n 1
            use="$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')"
            if [[ "${use:-0}" -ge 85 ]]; then
                echo "[WARN] Root file-system is ${use}% full."
            else
                echo "[OK] Root file-system usage is ${use}%."
            fi
            ;;

        *) echo "Invalid option." ;;
    esac
}
