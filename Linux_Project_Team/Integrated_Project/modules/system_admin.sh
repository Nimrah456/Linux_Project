#!/bin/bash
# OWNER: Member 1 - Linux System Administrator (Team Leader)
# Networking, service configuration, group administration, system info.

menu_sysadmin() {
    echo "--- System Administration ---"
    echo "1. Network Configuration Summary"
    echo "2. Service Status / Start / Stop / Restart"
    echo "3. Group Administration (add/remove user to lab_students)"
    echo "4. Update Package Index (apt-get update)"
    echo "5. OS and Kernel Information"

    read -r -p "Choose: " sa_opt

    case "$sa_opt" in
        1)
            echo "--- Hostname ---";        hostname
            echo "--- IP Addresses ---";    ip -brief address 2>/dev/null || hostname -I
            echo "--- Default Route ---";   ip route show default 2>/dev/null
            echo "--- DNS ---";             grep -E '^nameserver' /etc/resolv.conf 2>/dev/null
            echo "--- Listening Ports ---"; ss -tuln 2>/dev/null | head -n 15
            ;;

        2)
            local svc action
            read -r -p "Service name (ssh, cron, ufw, apache2...): " svc
            if [[ ! "$svc" =~ ^[a-zA-Z0-9@._-]+$ ]]; then
                echo "[FAIL] Invalid service name."; return 1
            fi
            read -r -p "Action (status/start/stop/restart/enable): " action
            case "$action" in
                status|start|stop|restart|enable)
                    systemctl "$action" "$svc" --no-pager
                    echo "$(date): systemctl $action $svc" >> logs/activity.log
                    ;;
                *) echo "Invalid action." ;;
            esac
            ;;

        3)
            local g_user g_action
            read -r -p "Lab username (lab_ prefix): " g_user
            if [[ ! "$g_user" =~ ^lab_[a-z0-9_-]+$ ]] || ! id "$g_user" &>/dev/null; then
                echo "Invalid or nonexistent lab user."; return 1
            fi
            if ! getent group lab_students >/dev/null; then
                echo "Group lab_students missing. Run Setup Lab Environment first."; return 1
            fi
            read -r -p "add or remove: " g_action
            case "$g_action" in
                add)    gpasswd -a "$g_user" lab_students && echo "$(date): $g_user added to lab_students" >> logs/activity.log ;;
                remove) gpasswd -d "$g_user" lab_students && echo "$(date): $g_user removed from lab_students" >> logs/activity.log ;;
                *)      echo "Invalid action." ;;
            esac
            ;;

        4)
            apt-get update && echo "$(date): apt index updated" >> logs/activity.log
            ;;

        5)
            grep -E '^(PRETTY_NAME|VERSION)=' /etc/os-release 2>/dev/null
            uname -a
            ;;

        *) echo "Invalid option." ;;
    esac
}
