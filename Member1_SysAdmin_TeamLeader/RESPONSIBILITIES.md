# Member 1 - Linux System Administrator (Team Leader)

## Duties
Linux installation, system configuration, package management, user and group administration, service configuration, networking.

## Code you own
- `main.sh` - integrates all modules (team leader)
- `modules/accounts.sh` - bulk create from CSV, list, lock, delete (lab_ safety prefix)
- `modules/environment.sh` - package install/verify, shared folder + lab_students group
- `modules/system_admin.sh` - network summary, service control, group membership, apt update, OS info
- `config/students.csv`, `config/packages.txt`

## Demo checklist (viva)
1. Show OS version and network summary (menu 3 -> 5, 1).
2. Bulk-create users from CSV; list them; lock and delete one.
3. Install packages from packages.txt; show `dpkg -s tree`.
4. Create lab_students group and the 2770 shared folder; add a user to the group.
5. Check/restart the `cron` or `ssh` service.

## Screenshots/evidence to collect
`ip a`, `id lab_john01`, `getent group lab_students`, `ls -ld shared_labs/common_data`, `systemctl status ssh`.
