#!/bin/bash
# Team Leader: Member 1 (integration of all modules)

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT" || exit 1

mkdir -p logs backups shared_labs

source modules/accounts.sh        # Member 1
source modules/environment.sh     # Member 1
source modules/system_admin.sh    # Member 1
source modules/storage.sh         # Member 2
source modules/automation.sh      # Member 3
source modules/security.sh        # Member 3
source modules/monitor.sh         # Member 4

if [[ "$EUID" -ne 0 ]]; then
    echo "Please run as root: sudo ./main.sh"
    exit 1
fi

if [[ "${1:-}" == "--cron-cleanup" ]]; then
    find /tmp -type f -mtime +7 -user root -delete 2>/dev/null
    echo "$(date): Scheduled cleanup completed" >> logs/activity.log
    echo "[OK] Scheduled cleanup completed."
    exit 0
fi

while true; do
    echo "========================================"
    echo " College Computer Laboratory Management"
    echo "========================================"
    echo "1. Manage Student Accounts          [Member 1]"
    echo "2. Setup Lab Environment            [Member 1]"
    echo "3. System Administration            [Member 1]"
    echo "4. Storage and Backup               [Member 2]"
    echo "5. Automation (Cleanup and Cron)    [Member 3]"
    echo "6. Security and Troubleshooting     [Member 3]"
    echo "7. Monitoring, Reports and Tests    [Member 4]"
    echo "8. Exit"

    read -r -p "Select an option: " opt

    case "$opt" in
        1) menu_accounts ;;
        2) menu_environment ;;
        3) menu_sysadmin ;;
        4) menu_storage ;;
        5) menu_automation ;;
        6) menu_security ;;
        7) menu_monitor ;;
        8) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
