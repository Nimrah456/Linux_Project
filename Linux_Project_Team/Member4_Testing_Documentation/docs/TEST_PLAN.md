# Test Plan

| ID | Area | Owner | Steps | Expected result | Pass/Fail |
|----|------|-------|-------|-----------------|-----------|
| T1 | Syntax | M4 | `bash tests/run_tests.sh` | All checks OK | |
| T2 | Bulk user creation | M1 | Menu 1 -> 1 | 3 lab_ users created; rerun says already exists | |
| T3 | Invalid user delete | M1 | Menu 1 -> 4 with `root` | Safety check failed | |
| T4 | Package install | M1 | Menu 2 -> 1 | tree, htop, curl installed | |
| T5 | Shared folder | M1 | Menu 2 -> 2 | Mode 2770 root:lab_students | |
| T6 | Network/services | M1 | Menu 3 -> 1, 2 | Output displayed, status shown | |
| T7 | Backup | M2 | Menu 4 -> 1, 3 | Archive created and verified | |
| T8 | Restore | M2 | Delete test file, Menu 4 -> 2 | File restored | |
| T9 | LVM/disk view | M2 | Menu 4 -> 4, 5, 6 | Devices, VGs, usage shown | |
| T10 | Cleanup | M3 | Menu 5 -> 1 then 2 | Dry run lists, execute needs CLEAN | |
| T11 | Cron | M3 | Menu 5 -> 3 twice, then 4 | Only one entry | |
| T12 | Firewall | M3 | Menu 6 -> 1, 2 | ufw active, 22/tcp allowed | |
| T13 | Permission audit | M3 | Menu 6 -> 3, 4 | [OK] mode 2770 | |
| T14 | Report | M4 | Menu 7 -> 4 | Report file in logs/ | |
