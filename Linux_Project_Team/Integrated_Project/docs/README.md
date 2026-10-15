# College Computer Laboratory Management System

A modular Bash application for Linux laboratory administration (Debian/Ubuntu).

## Run
    sudo ./main.sh          # interactive menu (root required)
    bash tests/run_tests.sh # automated tests (no root needed)

## Module ownership
| Menu | Module | Owner |
|------|--------|-------|
| 1 Student Accounts | modules/accounts.sh | Member 1 |
| 2 Lab Environment | modules/environment.sh | Member 1 |
| 3 System Administration | modules/system_admin.sh | Member 1 |
| 4 Storage and Backup | modules/storage.sh | Member 2 |
| 5 Automation (Cleanup/Cron) | modules/automation.sh | Member 3 |
| 6 Security and Troubleshooting | modules/security.sh | Member 3 |
| 7 Monitoring, Reports, Tests | modules/monitor.sh, tests/ | Member 4 |

Test in a disposable VM first. Only restore trusted backups.
