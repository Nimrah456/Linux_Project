#!/bin/bash
# OWNER: Member 3 - Automation & Security Engineer
# Firewall, permissions / access control, security audit, troubleshooting.

menu_security() {
    echo "--- Security and Troubleshooting ---"
    echo "1. Firewall Status (ufw)"
    echo "2. Enable Firewall (allow SSH first)"
    echo "3. Permission Audit of Shared Folder"
    echo "4. Fix Shared Folder Permissions (2770 root:lab_students)"
    echo "5. Security Audit (UID 0, empty passwords, world-writable)"
    echo "6. Troubleshooting (failed services, recent errors)"

    read -r -p "Choose: " sec_opt

    case "$sec_opt" in
        1)
            if command -v ufw >/dev/null 2>&1; then
                ufw status verbose
            else
                echo "ufw not installed (apt-get install ufw)."
            fi
            ;;

        2)
            local confirmation
            if ! command -v ufw >/dev/null 2>&1; then
                echo "ufw not installed (apt-get install ufw)."; return 1
            fi
            echo "WARNING: This allows SSH (22/tcp) and denies other incoming traffic."
            read -r -p "Type ENABLE to confirm: " confirmation
            if [[ "$confirmation" != "ENABLE" ]]; then
                echo "Cancelled."; return 0
            fi
            if ufw allow 22/tcp && ufw default deny incoming &&
               ufw default allow outgoing && ufw --force enable; then
                echo "[OK] Firewall enabled."
                echo "$(date): Firewall enabled" >> logs/activity.log
            else
                echo "[FAIL] Could not enable firewall."
                return 1
            fi
            ;;

        3)
            local mode
            if [[ -d shared_labs/common_data ]]; then
                stat -c '%A  owner=%U  group=%G  %n' shared_labs/common_data
                mode="$(stat -c '%a' shared_labs/common_data)"
                if [[ "$mode" == "2770" ]]; then
                    echo "[OK] Mode is 2770 (setgid, no access for others)."
                else
                    echo "[WARN] Mode is $mode, expected 2770."
                fi
            else
                echo "Shared folder not created yet (Setup Lab Environment)."
            fi
            ;;

        4)
            if [[ -d shared_labs/common_data ]] && getent group lab_students >/dev/null; then
                if chown root:lab_students shared_labs/common_data &&
                   chmod 2770 shared_labs/common_data; then
                    echo "[OK] Permissions reset."
                    echo "$(date): Shared folder permissions reset" >> logs/activity.log
                else
                    echo "[FAIL] Could not reset permissions."; return 1
                fi
            else
                echo "Shared folder or group missing."; return 1
            fi
            ;;

        5)
            echo "--- Accounts with UID 0 (should be only root) ---"
            awk -F: '$3 == 0 {print $1}' /etc/passwd
            echo "--- Accounts with empty password ---"
            awk -F: '$2 == "" {print $1}' /etc/shadow 2>/dev/null
            echo "--- World-writable files in project ---"
            find . -xdev -type f -perm -0002 2>/dev/null | head -n 20
            echo "--- Last 5 logins ---"
            last -n 5 2>/dev/null
            ;;

        6)
            echo "--- Failed systemd units ---"
            systemctl --failed --no-pager 2>/dev/null
            echo "--- Last 10 error-level journal entries ---"
            journalctl -p err -n 10 --no-pager 2>/dev/null || echo "journalctl not available"
            echo "--- Disk space ---"
            df -h / | tail -n 1
            ;;

        *) echo "Invalid option." ;;
    esac
}
