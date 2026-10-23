# 🖥️ College Computer Laboratory Management System

A Linux-based system administration and automation project developed using **Bash Shell Scripting, Python, Flask, HTML, CSS, and JavaScript**. The project simplifies common college computer laboratory management tasks through command-line utilities and a web-based monitoring dashboard.

## 📌 Project Overview

Managing a computer laboratory involves user account administration, storage allocation, backups, security configuration, automation, and system monitoring.

This project brings these tasks together in a modular Linux management system. It includes shell scripts for administrative operations and a Flask dashboard that provides a centralized interface for viewing system information and accessing selected management functions.

## ✨ Key Features

- **System Administration:** User and group management, package management, service configuration, and networking utilities.
- **Storage Management:** Disk inspection, filesystem information, Logical Volume Manager (LVM) inspection, and storage monitoring.
- **Backup and Recovery:** Utilities for creating and restoring backups.
- **Automation:** Bash-based maintenance tasks and scheduled operations using Cron.
- **Security Management:** Firewall status, SSH service monitoring, permissions, access control, and security auditing.
- **System Monitoring:** System information, operational logs, and administrative status checks.
- **Web Dashboard:** A Flask-powered interface for accessing system information and selected management operations.
- **Testing and Validation:** Scripts to verify system configuration, permissions, services, and other administrative requirements.

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| Ubuntu Linux | Operating environment |
| Bash Shell Scripting | System administration and automation |
| Python | Dashboard backend |
| Flask | Web application framework |
| HTML, CSS, JavaScript | Dashboard interface |
| Cron | Scheduled task automation |
| UFW | Firewall management |
| LVM2 | Logical volume inspection |
| Git and GitHub | Version control and collaboration |

## 🏗️ Project Structure

```text
Linux_Project/
├── Integrated_Project/          # Integrated command-line system
├── Member1_SysAdmin_TeamLeader/ # System administration
├── Member2_Storage_Backup/      # Storage and backup
├── Member3_Automation_Security/ # Automation and security
├── Member4_Testing_Documentation/ # Testing and documentation
├── member3-security/            # Security module
├── member4-testing/             # Testing utilities
├── web_dashboard/               # Flask web dashboard
├── main_dashboard.sh            # Dashboard launcher script
├── SETUP.md                     # Detailed setup instructions
├── TEAM_WORK_DIVISION.md        # Team responsibilities
└── README.md
```

## ⚙️ Installation and Setup

### Prerequisites

- Ubuntu Linux or an Ubuntu virtual machine
- Python 3
- Git
- Bash
- Appropriate permissions for administrative operations

Install the required system packages:

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip lvm2 ufw openssh-server tar
```

### 1. Clone the Repository

```bash
git clone https://github.com/Nimrah456/Linux_Project.git
cd Linux_Project
```

### 2. Set Up the Web Dashboard

```bash
cd web_dashboard
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install Flask
```

### 3. Run the Dashboard

```bash
python app.py
```

Open the following address in your browser:

```text
http://127.0.0.1:5000/
```

Keep the terminal running while using the dashboard. Press `Ctrl+C` to stop the Flask server.

For full system configuration, administrative helper setup, and testing instructions, refer to [SETUP.md](SETUP.md).

## 🧪 Testing

The repository includes a system audit script for checking relevant configuration and administrative requirements.

From the repository root, run:

```bash
bash member4-testing/run_test.sh
```

The checks cover items such as user accounts, class groups, shared-directory permissions, firewall status, SSH status, and network name resolution. Results depend on the configuration of the machine running the tests.

The dashboard also provides API endpoints for retrieving system information. For example, while the Flask application is running:

```bash
curl http://127.0.0.1:5000/api/storage
curl http://127.0.0.1:5000/api/audit
```

## 👥 Team Responsibilities

| Team Member | Responsibility |
|---|---|
| Member 1 — System Administrator and Team Leader | User and group administration, system configuration, packages, and services |
| Member 2 — Storage and Backup Administrator | Disk and filesystem management, LVM inspection, backup, and recovery |
| Member 3 — Automation and Security Engineer | Cron jobs, maintenance automation, firewall, permissions, and security |
| Member 4 — Testing and Documentation Lead | Testing, validation, technical documentation, reports, and presentation |

The complete module allocation is documented in [TEAM_WORK_DIVISION.md](TEAM_WORK_DIVISION.md).

## 🎯 Project Objectives

- Apply Linux commands and Bash scripting to practical system administration tasks.
- Automate repetitive computer laboratory management operations.
- Understand Linux users, groups, permissions, storage, and services.
- Implement basic backup, recovery, and security utilities.
- Integrate administrative scripts with a web-based dashboard.
- Practice modular development, testing, documentation, and team collaboration.

## 🔐 Security Considerations

- Run the project in an Ubuntu virtual machine or dedicated test environment.
- Review shell scripts before executing them with elevated privileges.
- Some operations can modify user accounts, file permissions, backups, and system services.
- Use restricted `sudo` permissions for privileged dashboard operations.
- Do not expose the development dashboard publicly without appropriate authentication and a security review.
- Never commit passwords, access tokens, or other sensitive credentials.

## 📚 Documentation

- [Setup and Execution Guide](SETUP.md)
- [Team Work Division](TEAM_WORK_DIVISION.md)
- [Project Source Code](https://github.com/Nimrah456/Linux_Project)

## 📌 Learning Outcomes

This project provides practical experience with Linux system administration, shell scripting, task automation, storage management, security controls, Python-based web development, and collaborative software development.

## 👩‍💻 Project Information

**Project:** College Computer Laboratory Management System  
**Domain:** Linux System Administration and Automation  
**Environment:** Ubuntu Linux  
**Backend:** Python and Flask  
**Scripting:** Bash  
**Frontend:** HTML, CSS, and JavaScript

---

Developed as an academic project to demonstrate practical Linux administration and computer laboratory management.
