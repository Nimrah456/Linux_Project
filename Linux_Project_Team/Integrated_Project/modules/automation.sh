#!/bin/bash
# OWNER: Member 3 - Automation & Security Engineer
# Cleanup scripts and cron scheduling.

menu_automation() {
    echo "--- Automation (Cleanup and Cron) ---"
    echo "1. Cleanup Dry Run"
    echo "2. Execute Cleanup"
    echo "3. Schedule Daily Cleanup (2 AM)"
    echo "4. Show Scheduled Cron Jobs"
    echo "5. Remove Scheduled Cleanup"

    read -r -p "Choose: " au_opt

    case "$au_opt" in
        1)
            find /tmp -type f -mtime +7 -user root -print 2>/dev/null
            ;;

        2)
            local confirmation
            read -r -p "Type CLEAN to confirm: " confirmation
            if [[ "$confirmation" != "CLEAN" ]]; then
                echo "Cleanup cancelled."
                return 0
            fi
            find /tmp -type f -mtime +7 -user root -delete 2>/dev/null
            echo "$(date): Cleanup executed" >> logs/activity.log
            echo "Cleanup completed."
            ;;

        3)
            local project_path cron_command
            project_path="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
            cron_command="0 2 * * * /bin/bash \"$project_path/main.sh\" --cron-cleanup"

            # FIX: match on the flag only. The stored line has quotes around the
            # path, so the original grep never matched and created duplicates.
            if crontab -l 2>/dev/null | grep -Fq -- "--cron-cleanup"; then
                echo "Scheduled cleanup already exists."
            else
                if (crontab -l 2>/dev/null || true; echo "$cron_command") | crontab -; then
                    echo "Daily cleanup scheduled for 2 AM."
                    echo "$(date): Cron cleanup scheduled" >> logs/activity.log
                else
                    echo "[FAIL] Could not schedule cleanup."
                    return 1
                fi
            fi
            ;;

        4)
            crontab -l 2>/dev/null || echo "No cron jobs for root."
            ;;

        5)
            if crontab -l 2>/dev/null | grep -Fq -- "--cron-cleanup"; then
                crontab -l | grep -Fv -- "--cron-cleanup" | crontab -
                echo "Scheduled cleanup removed."
                echo "$(date): Cron cleanup removed" >> logs/activity.log
            else
                echo "No scheduled cleanup found."
            fi
            ;;

        *) echo "Invalid option." ;;
    esac
}
