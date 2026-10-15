#!/bin/bash
# OWNER: Member 4 - Testing, Documentation & Presentation Lead
# Monitoring, reports and test runner.

menu_monitor() {
    echo "--- System Monitor, Reports and Tests ---"
    echo "1. View Active Users"
    echo "2. System Resources"
    echo "3. View Activity Log"
    echo "4. Generate System Report (saved to logs/)"
    echo "5. Run Automated Tests"

    read -r -p "Choose: " mon_opt

    case "$mon_opt" in
        1)
            who
            ;;

        2)
            echo "--- Uptime ---"
            uptime
            echo "--- Memory ---"
            free -h
            echo "--- Disk ---"
            df -h /
            ;;

        3)
            if [[ -f logs/activity.log ]]; then
                tail -n 20 logs/activity.log
            else
                echo "No logs found."
            fi
            ;;

        4)
            local report
            report="logs/report_$(date +'%Y%m%d_%H%M%S').txt"
            {
                echo "Lab System Report - $(date)"
                echo "Host: $(hostname)"
                echo "--- Uptime ---";      uptime
                echo "--- Memory ---";      free -h
                echo "--- Disk ---";        df -h /
                echo "--- Lab Users ---";   awk -F: '/^lab_/ {print $1 " - " $5}' /etc/passwd
                echo "--- Backups ---";     ls -lh backups/*.tar.gz 2>/dev/null || echo "none"
                echo "--- Recent Activity ---"
                tail -n 20 logs/activity.log 2>/dev/null || echo "none"
            } > "$report"
            echo "[OK] Report saved: $report"
            echo "$(date): Report generated: $report" >> logs/activity.log
            ;;

        5)
            bash tests/run_tests.sh
            ;;

        *)
            echo "Invalid option."
            ;;
    esac
}
