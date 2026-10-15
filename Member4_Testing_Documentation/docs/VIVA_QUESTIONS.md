# Viva Questions and Answers

## 1. Why use -m in useradd?
It creates the user's home directory.

## 2. How does dry-run cleanup work?
It uses find with -print to display files without deleting them.

## 3. How are managed users protected?
The account functions validate usernames and require the lab_ prefix for disabling and deleting users.

## 4. What does chmod 2770 do?
It grants full permissions to the owner and group, denies permissions to others, and sets the setgid bit.

## 5. Why use separate Bash modules?
Modules improve maintainability, testing, and organization.

## 6. What is cron?
Cron schedules commands to run at specified times.

## 7. Why create backups?
Backups provide copies of configuration and shared data for recovery.

## 8. What does bash -n do?
It checks Bash syntax without executing the script.

## 9. Why inspect backup archives?
Untrusted archives can contain unexpected paths or files.

## 10. Why check exit codes?
Exit codes help detect failures and prevent false success reports.

## Additional questions by role

### Member 1
- What is the difference between `usermod -L` and `userdel -r`?
- Why do we use `systemctl enable` versus `start`?
- What does the setgid bit on a directory do?

### Member 2
- What is the relationship between PV, VG and LV in LVM?
- Why verify a backup with `tar -tzf` before restoring?
- What does `lsblk -f` show that `df -h` does not?

### Member 3
- Explain the cron line `0 2 * * *`.
- Why allow SSH before enabling `ufw`?
- Why must cron jobs use absolute paths?

### Member 4
- What is the difference between syntax testing and functional testing?
- Why test in a VM snapshot?
- How do you validate that a script reported success truthfully (exit codes)?
