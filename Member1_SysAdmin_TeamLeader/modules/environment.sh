#!/bin/bash

menu_environment() {
    echo "--- Lab Environment ---"
    echo "1. Install and Verify Software"
    echo "2. Create Shared Folders and Groups"

    read -r -p "Choose: " env_opt

    case "$env_opt" in
        1)
            local pkg

            if [[ ! -r config/packages.txt ]]; then
                echo "[FAIL] Cannot read config/packages.txt"
                return 1
            fi

            while IFS= read -r pkg || [[ -n "$pkg" ]]; do
                [[ -z "$pkg" || "$pkg" == \#* ]] && continue

                if [[ ! "$pkg" =~ ^[a-z0-9][a-z0-9+.-]*$ ]]; then
                    echo "[WARN] Invalid package name: $pkg"
                    continue
                fi

                if dpkg -s "$pkg" &>/dev/null; then
                    echo "$pkg is already installed."
                else
                    echo "Installing $pkg..."
                    if apt-get install -y "$pkg"; then
                        echo "$(date): Installed software $pkg" >> logs/activity.log
                    else
                        echo "[FAIL] Installation failed: $pkg"
                    fi
                fi
            done < config/packages.txt
            ;;

        2)
            if ! getent group lab_students >/dev/null; then
                groupadd lab_students || {
                    echo "[FAIL] Could not create group."
                    return 1
                }
            fi

            mkdir -p shared_labs/common_data || return 1

            if chown root:lab_students shared_labs/common_data &&
               chmod 2770 shared_labs/common_data; then
                echo "Shared folder configured successfully."
                echo "$(date): Configured shared folder" >> logs/activity.log
            else
                echo "[FAIL] Could not configure shared folder."
                return 1
            fi
            ;;

        *)
            echo "Invalid option."
            ;;
    esac
}
