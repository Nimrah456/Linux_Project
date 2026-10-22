# Linux Infrastructure Automation Dashboard

## 1. Project Overview

This project is a Linux administration system with a web-based dashboard built using Python, Flask, HTML, CSS, JavaScript, and Bash scripting.

The dashboard provides a central interface for monitoring and managing:

- User Management
- Permissions
- Storage Management
- Backup and Recovery
- Firewall and Security
- Automation
- System Audit

The application uses Linux commands and Bash scripts to retrieve system information and perform selected administrative tasks.

## 2. Requirements

The project is designed to run on an Ubuntu Linux system or virtual machine.

Install the required system packages:

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip lvm2 ufw openssh-server tar
```

You will also need:
- GitHub access to download the project.
- Python 3 and a Python virtual environment.
- Appropriate Linux permissions for administrative operations.
- An Ubuntu environment configured for the project modules.

**Important:** Run this project in a virtual machine or test environment. Some scripts can create user accounts, change directory permissions, manage backups, or interact with system services.

## 3. Download the Project

Clone the repository:

```bash
git clone https://github.com/Nimrah456/Linux_Project.git
```

Enter the project directory:

```bash
cd Linux_Project
```

## 4. Set Up the Python Environment

Navigate to the web dashboard directory:

```bash
cd web_dashboard
```

Create a virtual environment:

```bash
python3 -m venv .venv
```

Activate it:

```bash
source .venv/bin/activate
```

Install Flask:

```bash
python -m pip install --upgrade pip
python -m pip install Flask
```

Check the Python application for syntax errors:

```bash
python -m py_compile app.py
```

If the command completes without displaying an error, the Python syntax check has passed.

## 5. Start the Dashboard

From the `web_dashboard` directory, run:

```bash
python app.py
```

Open your browser and visit:

http://127.0.0.1:5000/

The dashboard should display the Linux Infrastructure Dashboard.

Keep the terminal running while using the application.

To stop the Flask server, press `Ctrl+C` in the terminal.

## 6. Configure the Linux Environment

Some dashboard features depend on the configuration of the Linux system.

### User Management and Permissions

The project includes scripts in:

```text
member1-sysadmin/
```

The environment may require student accounts, class groups, and shared directories.

The demonstrated configuration uses 100 student accounts, the groups `class_a`, `class_b`, and `class_c`, and shared directories under `/data/`.

Review the scripts before executing them. They can modify Linux accounts, groups, ownership, and permissions.

### Storage Management

The Storage Management module uses the following commands:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
pvs
vgs
lvs
df -hT
```

The `pvs`, `vgs`, and `lvs` commands require the LVM2 package.

On this project setup, the Flask application uses restricted `sudo` permissions to execute these commands.

If the system does not have LVM volumes configured, the LVM commands may return empty results. This is normal and does not mean the commands are missing.

**Do not initialize or format a disk simply to make the dashboard display LVM data.** Review the relevant storage script before using it because storage initialization can modify disk contents.

### Backup and Recovery

The backup module uses the helper script:

```text
web_dashboard/backup_dashboard_helper.sh
```

The demonstrated setup installs a root-owned copy at:

```text
/usr/local/sbin/linux-project-backup-dashboard
```

The helper and its restricted `sudo` configuration must be installed on the Ubuntu system where the application will run.

### Firewall and Security

The security module uses:

```text
web_dashboard/security_dashboard_helper.sh
```

The demonstrated setup installs the helper at:

```text
/usr/local/sbin/linux-project-security-dashboard
```

It reports information about UFW and SSH services.

The dashboard's security integration also requires the corresponding restricted `sudo` permissions.

If reproducing this configuration, review the helper scripts first and validate any `sudoers` files with `visudo`. Do not grant unrestricted administrator access to the Flask application.

## 7. Run the System Audit

The project includes:

```text
member4-testing/run_test.sh
```

From the project root, execute:

```bash
bash member4-testing/run_test.sh
```

The script checks the testing directory, student accounts, class groups, shared directory permissions, firewall status, SSH status, and network name resolution.

A successful run displays a summary of passed and failed checks.

Results depend on the configuration of the Linux system where the script runs.

## 8. Test the Dashboard APIs

While Flask is running, open another terminal and try:

```bash
curl http://127.0.0.1:5000/api/storage
```

```bash
curl http://127.0.0.1:5000/api/audit
```

The storage endpoint returns the results of the five storage inspection commands.

The audit endpoint executes the system audit script and returns its results as JSON.

Other endpoints provide information about the system, users, backups, security, and automation.

## 9. Troubleshooting

### Flask command or module errors

Activate the virtual environment and verify Flask is installed:

```bash
cd ~/Linux_Project/web_dashboard
source .venv/bin/activate
python -m pip show Flask
```

### Port 5000 is already in use

Another Flask server may already be running. Stop the existing server using `Ctrl+C` in its terminal before starting another instance.

### Storage commands report permission errors

Verify that LVM2 is installed and that the restricted `sudo` configuration is correct.

### Backup or security information is unavailable

Verify that the relevant helper script is installed at the expected path, that it is executable and root-owned, and that its `sudoers` configuration is valid.

### Results differ on another computer

The dashboard reports information about the Linux machine running the Flask backend. User accounts, groups, disks, firewall rules, SSH services, and available backups will differ between systems.

## 10. Security Notes

- Use a virtual machine for testing administrative scripts.
- Review shell scripts before executing them with `sudo`.
- Do not upload passwords, API keys, or other secrets to GitHub.
- Keep virtual environments and temporary files out of version control.
- Do not expose this dashboard publicly without proper authentication and a security review.
- The Flask development server is intended for development and demonstration, not production deployment.

## 11. Repository

GitHub: https://github.com/Nimrah456/Linux_Project

The repository contains the Bash scripts, Flask backend, frontend files, and supporting utilities required for the project.

---

**Project:** Linux Infrastructure Automation Dashboard  
**Environment:** Ubuntu Linux  
**Backend:** Python and Flask  
**Frontend:** HTML, CSS, and JavaScript  
**Automation:** Bash scripting and Linux administration commands
