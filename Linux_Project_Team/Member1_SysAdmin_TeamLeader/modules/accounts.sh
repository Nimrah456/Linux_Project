#!/bin/bash

menu_accounts() {
    echo "--- Account Management ---"
    echo "1. Bulk Create from CSV"
    echo "2. List Lab Users"
    echo "3. Disable User"
    echo "4. Delete User"

    read -r -p "Choose: " acc_opt

    case "$acc_opt" in
        1)
            local username fullname

            if [[ ! -r config/students.csv ]]; then
                echo "[FAIL] Cannot read config/students.csv"
                return 1
            fi

            while IFS=, read -r username fullname || [[ -n "${username:-}" ]]; do
                username="${username%$'\r'}"
                fullname="${fullname%$'\r'}"

                if [[ "$username" == "username" || -z "$username" ]]; then
                    continue
                fi

                if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                    echo "[WARN] Invalid username: $username"
                    continue
                fi

                if [[ "$username" != lab_* ]]; then
                    username="lab_$username"
                fi

                if id "$username" &>/dev/null; then
                    echo "User $username already exists."
                    continue
                fi

                if useradd -m -c "$fullname" -s /bin/bash "$username"; then
                    echo "[OK] Created user: $username"
                    echo "$(date): Created user $username" >> logs/activity.log
                else
                    echo "[FAIL] Could not create user: $username"
                fi
            done < config/students.csv
            ;;

        2)
            awk -F: '/^lab_/ {print $1 " - " $5}' /etc/passwd
            ;;

        3)
            local d_user

            read -r -p "Username to disable (lab_ prefix required): " d_user

            if [[ "$d_user" =~ ^lab_[a-z0-9_-]+$ ]] &&
               id "$d_user" &>/dev/null; then
                if usermod -L "$d_user"; then
                    echo "User $d_user disabled."
                    echo "$(date): Disabled user $d_user" >> logs/activity.log
                else
                    echo "[FAIL] Could not disable user."
                fi
            else
                echo "Invalid or nonexistent lab user."
            fi
            ;;

        4)
            local del_user confirmation

            read -r -p "Username to delete (lab_ prefix required): " del_user

            if [[ "$del_user" =~ ^lab_[a-z0-9_-]+$ ]] &&
               id "$del_user" &>/dev/null; then

                read -r -p "Type DELETE to confirm: " confirmation

                if [[ "$confirmation" != "DELETE" ]]; then
                    echo "Deletion cancelled."
                    return 0
                fi

                if userdel -r "$del_user"; then
                    echo "User $del_user deleted."
                    echo "$(date): Deleted user $del_user" >> logs/activity.log
                else
                    echo "[FAIL] Could not delete user."
                fi
            else
                echo "Safety check failed: invalid lab user."
            fi
            ;;

        *)
            echo "Invalid option."
            ;;
    esac
}
