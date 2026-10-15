# Team Work Division - College Computer Laboratory Management System

| Role | Deliverable folder | Code owned |
|------|--------------------|-----------|
| Member 1 - Linux System Administrator (Team Leader) | Member1_SysAdmin_TeamLeader/ | accounts.sh, environment.sh, system_admin.sh, main.sh, packages.txt, students.csv |
| Member 2 - Storage & Backup Administrator | Member2_Storage_Backup/ | storage.sh |
| Member 3 - Automation & Security Engineer | Member3_Automation_Security/ | automation.sh, security.sh |
| Member 4 - Testing, Documentation & Presentation Lead | Member4_Testing_Documentation/ | monitor.sh, tests/run_tests.sh, docs/ |

`Integrated_Project/` contains the complete working system with every module combined.

## Mapping to the role table
**Member 1** - installation/system config (system_admin.sh option 5, 4), package management (environment.sh option 1, packages.txt), user and group administration (accounts.sh, system_admin.sh option 3), service configuration (option 2), networking (option 1).
**Member 2** - partitioning and file-system management (storage.sh 4), LVM (5), backup and recovery (1, 2, 3), storage allocation and validation (6).
**Member 3** - shell scripting and Cron (automation.sh), firewall (security.sh 1-2), permissions and access control (3-4), system security (5), troubleshooting (6).
**Member 4** - system testing and validation (tests/run_tests.sh), technical documentation and report (docs/, reports via monitor.sh option 4), presentation and viva coordination (PRESENTATION_OUTLINE.md, VIVA_QUESTIONS.md, DEMO_SCRIPT.md).

## Changes made when splitting the original project
- `maintenance.sh` was split: backup/restore moved to **storage.sh** (Member 2); cleanup and cron moved to **automation.sh** (Member 3).
- New modules added to cover role duties the original lacked: system_admin.sh (networking, services, groups), security.sh (firewall, permissions, audit, troubleshooting), plus LVM/disk overview in storage.sh.
- Bug fixed: the cron duplicate check never matched (the stored line quotes the path), so scheduling twice created duplicate jobs. It now matches on `--cron-cleanup`.
- `main.sh` now creates `logs/`, `backups/` and `shared_labs/` if missing (they were absent from the zip, so logging failed on first run).
- LVM and partition features are read-only inspections by design; actual partitioning/LVM creation should be demonstrated manually in the VM and documented as screenshots.

## Integration order
1. Member 1 installs the OS and base configuration, creates users and groups.
2. Member 2 prepares storage and takes the first backup.
3. Member 3 hardens permissions/firewall and schedules cron.
4. Member 4 runs tests, collects screenshots, writes the report.
