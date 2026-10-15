# Member 3 - Automation & Security Engineer

## Duties
Shell scripting, Cron scheduling, firewall configuration, permissions, access control, system security, troubleshooting.

## Code you own
- `modules/automation.sh` - cleanup dry-run/execute, schedule/list/remove cron job (includes the duplicate-cron bug fix)
- `modules/security.sh` - ufw firewall, shared-folder permission audit/fix, security audit, troubleshooting

## Demo checklist (viva)
1. Dry run cleanup, then confirmed cleanup (`CLEAN`).
2. Schedule cron, show `crontab -l`, try again (no duplicate), remove it.
3. Show firewall status; enable it with SSH allowed.
4. Audit shared folder perms (expect 2770); explain setgid.
5. Run security audit and troubleshooting view.

## Explain the cron line
`0 2 * * *` = minute 0, hour 2, every day, every month, every weekday.
