#!/bin/bash
while true; do
 clear
 echo "================================================="
 echo " LINUX INFRASTRUCTURE MANAGEMENT DASHBOARD "
 echo "================================================="
 echo "1. Provision User Accounts & Permissions (Member 1)"
 echo "2. Configure Storage & Disaster Recovery (Member 2)"
 echo "3. Setup Perimeter Security & Firewall (Member 3)"
 echo "4. Run System Audit & Validation (Member 4)"
 echo "5. Exit Dashboard"
 echo "================================================="
 read -p "Enter your choice [1-5]: " choice
 case $choice in
 1) sudo ./member1-sysadmin/create_users.sh; sudo ./member1-sysadmin/set_permissions.sh; read -p "Press [Enter] to return to menu..." ;;
 2) sudo ./member2-storage/lvm_setup.sh; sudo ./member2-storage/lab_backup.sh; read -p "Press [Enter] to return to menu..." ;;
 3) sudo ./member3-security/security_setup.sh; sudo ./member3-security/lab_cleanup.sh; read -p "Press [Enter] to return to menu..." ;;
 4) sudo ./member4-testing/system_test.sh; read -p "Press [Enter] to return to menu..." ;;
 5) echo "Exiting Dashboard. Goodbye!"; exit 0 ;;
 *) echo "[!] ERROR: Invalid choice. Please enter a number between 1 and 5."; sleep 2 ;;
 esac
done
