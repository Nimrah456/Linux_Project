from flask import Flask, jsonify, send_from_directory, request

import grp
import os
import platform
import pwd
import re
import shutil
import socket
import subprocess


# =====================================================
# APPLICATION CONFIGURATION
# =====================================================

app = Flask(__name__)

PROJECT_ROOT = os.path.dirname(app.root_path)

BACKUP_HELPER = (
    "/usr/local/sbin/linux-project-backup-dashboard"
)

SECURITY_HELPER = (
    "/usr/local/sbin/linux-project-security-dashboard"
)

BACKUP_PATTERN = re.compile(
    r"^lab_data_backup_\d{4}-\d{2}-\d{2}_"
    r"\d{2}-\d{2}-\d{2}\.tar\.gz$"
)


# =====================================================
# FRONTEND ROUTES
# =====================================================

@app.route("/")
def home():
    return send_from_directory(
        app.root_path,
        "index.html"
    )


@app.route("/style.css")
def stylesheet():
    return send_from_directory(
        app.root_path,
        "style.css"
    )


# =====================================================
# HELPER: STUDENT ACCOUNT INFORMATION
# =====================================================

def get_student_accounts():

    students = []

    groups = grp.getgrall()

    expected_groups = {
        "class_a",
        "class_b",
        "class_c"
    }

    for user in pwd.getpwall():

        match = re.fullmatch(
            r"student(\d+)",
            user.pw_name
        )

        if not match:
            continue

        memberships = []

        for group in groups:

            belongs_to_group = (
                user.pw_gid == group.gr_gid
                or user.pw_name in group.gr_mem
            )

            if (
                belongs_to_group
                and group.gr_name in expected_groups
            ):
                memberships.append(group.gr_name)

        students.append({
            "username": user.pw_name,

            "class_group": (
                ", ".join(sorted(set(memberships)))
                if memberships
                else "Not assigned"
            ),

            "home_directory": user.pw_dir,

            "login_shell": user.pw_shell
        })

    students.sort(
        key=lambda item: int(
            item["username"][7:]
        )
    )

    return students


# =====================================================
# SYSTEM OVERVIEW API
# URL: /api/system
# =====================================================

@app.route("/api/system")
def system_info():

    try:
        os_info = platform.freedesktop_os_release()

        os_name = os_info.get(
            "PRETTY_NAME",
            platform.system()
        )

    except (OSError, AttributeError):
        os_name = platform.system()

    students = get_student_accounts()

    class_groups = {}

    for group_name in [
        "class_a",
        "class_b",
        "class_c"
    ]:

        try:
            grp.getgrnam(group_name)

            class_groups[group_name] = True

        except KeyError:
            class_groups[group_name] = False

    shared_directories = {}

    for directory in [
        "/data/shared1",
        "/data/shared2",
        "/data/shared3"
    ]:

        shared_directories[directory] = (
            os.path.isdir(directory)
        )

    disk = shutil.disk_usage("/")

    return jsonify({

        "hostname": socket.gethostname(),

        "operating_system": os_name,

        "student_accounts": len(students),

        "class_groups": class_groups,

        "shared_directories": shared_directories,

        "root_disk": {

            "total_gb": round(
                disk.total / (1024 ** 3),
                2
            ),

            "free_gb": round(
                disk.free / (1024 ** 3),
                2
            )
        }
    })


# =====================================================
# USER MANAGEMENT API
# URL: /api/users
# =====================================================

@app.route("/api/users")
def user_list():

    students = get_student_accounts()

    return jsonify({

        "count": len(students),

        "users": students
    })


# =====================================================
# HELPER: RUN READ-ONLY LINUX COMMANDS
# =====================================================

def run_readonly_command(arguments):

    try:

        result = subprocess.run(
            arguments,
            capture_output=True,
            text=True,
            timeout=10,
            check=False
        )

        return {

            "ok": result.returncode == 0,

            "output": result.stdout.strip(),

            "error": result.stderr.strip()
        }

    except subprocess.TimeoutExpired:

        return {

            "ok": False,

            "output": "",

            "error": "Command timed out."
        }

    except OSError as error:

        return {

            "ok": False,

            "output": "",

            "error": str(error)
        }


# =====================================================
# STORAGE MANAGEMENT API
# URL: /api/storage
# =====================================================

@app.route("/api/storage")
def storage_info():

    commands = [

        (
            "Block Devices and Filesystems",

            [
                "lsblk",
                "-o",
                "NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"
            ]
        ),

        (
            "LVM Physical Volumes",

            ["sudo", "-n", "/usr/sbin/pvs"]
        ),

        (
            "LVM Volume Groups",

            ["sudo", "-n", "/usr/sbin/vgs"]
        ),

        (
            "LVM Logical Volumes",

            ["sudo", "-n", "/usr/sbin/lvs"]
        ),

        (
            "Filesystem Disk Usage",

            ["df", "-hT"]
        )
    ]

    checks = []

    for title, command in commands:

        result = run_readonly_command(command)

        checks.append({

            "title": title,

            "command": " ".join(command),

            "ok": result["ok"],

            "output": result["output"],

            "error": result["error"]
        })

    return jsonify({

        "checks": checks
    })


# =====================================================
# HELPER: RUN THE RESTRICTED BACKUP HELPER
# =====================================================

def run_backup_helper(arguments, timeout=30):

    try:

        result = subprocess.run(

            [
                "sudo",
                "-n",
                BACKUP_HELPER,
                *arguments
            ],

            capture_output=True,

            text=True,

            timeout=timeout,

            check=False
        )

        return {

            "ok": result.returncode == 0,

            "output": result.stdout.strip(),

            "error": result.stderr.strip()
        }

    except subprocess.TimeoutExpired:

        return {

            "ok": False,

            "output": "",

            "error": "Backup operation timed out."
        }

    except OSError as error:

        return {

            "ok": False,

            "output": "",

            "error": str(error)
        }


# =====================================================
# HELPER: READ BACKUP LIST
# =====================================================

def get_backups():

    result = run_backup_helper(["list"])

    if not result["ok"]:

        return (
            None,
            result["error"] or result["output"]
        )

    backups = []

    for line in result["output"].splitlines():

        parts = line.split("|", 2)

        if len(parts) != 3:
            continue

        path, size_text, modified = parts

        filename = os.path.basename(path)

        if os.path.dirname(path) != "/backup":
            continue

        if not BACKUP_PATTERN.fullmatch(filename):
            continue

        try:

            size_bytes = int(size_text)

        except ValueError:
            continue

        backups.append({

            "filename": filename,

            "size_bytes": size_bytes,

            "modified": modified
        })

    backups.sort(
        key=lambda item: item["filename"],
        reverse=True
    )

    return backups, None


# =====================================================
# BACKUP LIST API
# URL: /api/backups
# =====================================================

@app.route("/api/backups", methods=["GET"])
def backup_list():

    backups, error = get_backups()

    if error:

        return jsonify({

            "ok": False,

            "error": error

        }), 503

    return jsonify({

        "ok": True,

        "count": len(backups),

        "backups": backups
    })


# =====================================================
# BACKUP INSPECTION API
# URL: /api/backups/inspect
# =====================================================

@app.route(
    "/api/backups/inspect",
    methods=["POST"]
)
def backup_inspect():

    if not request.is_json:

        return jsonify({

            "ok": False,

            "error": "JSON request required."

        }), 400

    data = request.get_json(silent=True) or {}

    filename = data.get("filename", "")

    if (

        not isinstance(filename, str)

        or not BACKUP_PATTERN.fullmatch(filename)

    ):

        return jsonify({

            "ok": False,

            "error": "Invalid backup filename."

        }), 400

    result = run_backup_helper(

        ["inspect", filename],

        timeout=30
    )

    if not result["ok"]:

        return jsonify({

            "ok": False,

            "error": (
                result["error"]
                or "Unable to inspect archive."
            ),

            "output": result["output"]

        }), 422

    return jsonify({

        "ok": True,

        "filename": filename,

        "output": result["output"]
    })


# =====================================================
# CREATE BACKUP API
# URL: /api/backups/create
# =====================================================

@app.route(
    "/api/backups/create",
    methods=["POST"]
)
def backup_create():

    if not request.is_json:

        return jsonify({

            "ok": False,

            "error": "JSON request required."

        }), 400

    data = request.get_json(silent=True) or {}

    if data.get("confirm") is not True:

        return jsonify({

            "ok": False,

            "error": "Explicit confirmation is required."

        }), 400

    result = run_backup_helper(

        ["create"],

        timeout=180
    )

    if not result["ok"]:

        return jsonify({

            "ok": False,

            "error": (
                result["error"]
                or "Backup creation failed."
            ),

            "output": result["output"]

        }), 500

    backups, list_error = get_backups()

    return jsonify({

        "ok": True,

        "message": (
            "Backup created and integrity check passed."
        ),

        "output": result["output"],

        "count": (
            len(backups)
            if backups is not None
            else None
        ),

        "backups": backups,

        "warning": list_error
    })


# =====================================================
# FIREWALL AND SECURITY API
# URL: /api/security
# =====================================================

@app.route("/api/security")
def security_info():

    try:

        result = subprocess.run(

            [
                "sudo",
                "-n",
                SECURITY_HELPER
            ],

            capture_output=True,

            text=True,

            timeout=12,

            check=False
        )

    except subprocess.TimeoutExpired:

        return jsonify({

            "ok": False,

            "error": "Security status check timed out."

        }), 504

    except OSError as error:

        return jsonify({

            "ok": False,

            "error": str(error)

        }), 500

    output = result.stdout.strip()

    error = result.stderr.strip()

    if result.returncode != 0:

        return jsonify({

            "ok": False,

            "error": (
                error
                or output
                or "Unable to retrieve security status."
            )

        }), 503

    match = re.search(

        r"^Status:\s*(active|inactive)\s*$",

        output,

        re.MULTILINE | re.IGNORECASE
    )

    firewall_status = (

        match.group(1).lower()

        if match

        else "unknown"
    )

    return jsonify({

        "ok": True,

        "firewall_status": firewall_status,

        "output": output
    })


# =====================================================
# CLEANUP AND AUTOMATION API
# URL: /api/automation
# =====================================================

@app.route("/api/automation")
def automation_info():

    project_crontab = os.path.join(

        PROJECT_ROOT,

        "member3-security",

        "crontab.txt"
    )

    cleanup_script = os.path.join(

        PROJECT_ROOT,

        "member3-security",

        "lab_cleanup.sh"
    )

    backup_script = os.path.join(

        PROJECT_ROOT,

        "member2-storage",

        "lab_backup.sh"
    )

    sections = []

    # -------------------------------------------------
    # 1. Cron service status
    # -------------------------------------------------

    try:

        result = subprocess.run(

            [
                "systemctl",
                "is-active",
                "cron"
            ],

            capture_output=True,

            text=True,

            timeout=5,

            check=False
        )

        output = (

            result.stdout.strip()

            or result.stderr.strip()

            or "No status returned."
        )

        sections.append({

            "title": "Cron Service Status",

            "source": "systemctl is-active cron",

            "ok": result.returncode == 0,

            "output": output
        })

    except (OSError, subprocess.TimeoutExpired) as error:

        sections.append({

            "title": "Cron Service Status",

            "source": "systemctl is-active cron",

            "ok": False,

            "output": str(error)
        })

    # -------------------------------------------------
    # 2. Current user's crontab
    # -------------------------------------------------

    try:

        result = subprocess.run(

            ["crontab", "-l"],

            capture_output=True,

            text=True,

            timeout=5,

            check=False
        )

        no_crontab = (

            "no crontab for"

            in result.stderr.lower()
        )

        if result.returncode == 0:

            output = (

                result.stdout.strip()

                or "The current user's crontab is empty."
            )

            ok = True

        elif no_crontab:

            output = (
                "No personal crontab is configured for this user."
            )

            ok = True

        else:

            output = (

                result.stderr.strip()

                or "Unable to read the current user's crontab."
            )

            ok = False

        sections.append({

            "title": "Current User's Scheduled Jobs",

            "source": "crontab -l",

            "ok": ok,

            "output": output
        })

    except (OSError, subprocess.TimeoutExpired) as error:

        sections.append({

            "title": "Current User's Scheduled Jobs",

            "source": "crontab -l",

            "ok": False,

            "output": str(error)
        })

    # -------------------------------------------------
    # 3. Project cron reference file
    # -------------------------------------------------

    if os.path.isfile(project_crontab):

        try:

            with open(

                project_crontab,

                "r",

                encoding="utf-8"

            ) as file:

                output = file.read().strip()

            if not output:

                output = "The configuration file is empty."

            sections.append({

                "title": "Project Cron Configuration",

                "source": project_crontab,

                "ok": True,

                "output": output
            })

        except OSError as error:

            sections.append({

                "title": "Project Cron Configuration",

                "source": project_crontab,

                "ok": False,

                "output": str(error)
            })

    else:

        sections.append({

            "title": "Project Cron Configuration",

            "source": project_crontab,

            "ok": False,

            "output": "Project crontab.txt was not found."
        })

    # -------------------------------------------------
    # 4. System-wide cron configuration
    # -------------------------------------------------

    system_crontab = "/etc/crontab"

    if os.path.isfile(system_crontab):

        try:

            with open(

                system_crontab,

                "r",

                encoding="utf-8"

            ) as file:

                output = file.read().strip()

            if not output:

                output = "System crontab is empty."

            sections.append({

                "title": "System-Wide Cron Configuration",

                "source": system_crontab,

                "ok": True,

                "output": output
            })

        except OSError as error:

            sections.append({

                "title": "System-Wide Cron Configuration",

                "source": system_crontab,

                "ok": False,

                "output": str(error)
            })

    # -------------------------------------------------
    # 5. Check cleanup and backup scripts
    # -------------------------------------------------

    for title, script_path in [

        ("Cleanup Script", cleanup_script),

        ("Backup Script", backup_script)

    ]:

        exists = os.path.isfile(script_path)

        sections.append({

            "title": title,

            "source": script_path,

            "ok": exists,

            "output": (

                "Script exists."

                if exists

                else "Script was not found."
            )
        })

    return jsonify({

        "ok": True,

        "sections": sections
    })

# =====================================================
# PERMISSIONS AND ACCESS CONTROL API
# URL: /api/permissions
# =====================================================

@app.route("/api/permissions")
def permissions_info():

    import stat

    expected_groups = [
        "class_a",
        "class_b",
        "class_c"
    ]

    expected_directories = [
        {
            "path": "/data/shared1",
            "expected_group": "class_a"
        },
        {
            "path": "/data/shared2",
            "expected_group": "class_b"
        },
        {
            "path": "/data/shared3",
            "expected_group": "class_c"
        }
    ]

    # -------------------------------------------------
    # 1. Collect actual Linux group information
    # -------------------------------------------------

    groups = []

    for group_name in expected_groups:

        try:
            group = grp.getgrnam(group_name)

            # Include users whose primary group or
            # supplementary group is this class group.
            members = []

            for user in pwd.getpwall():

                if (
                    user.pw_gid == group.gr_gid
                    or user.pw_name in group.gr_mem
                ):
                    members.append(user.pw_name)

            groups.append({
                "name": group.gr_name,
                "gid": group.gr_gid,
                "exists": True,
                "member_count": len(members),
                "members": sorted(set(members))
            })

        except KeyError:

            groups.append({
                "name": group_name,
                "gid": None,
                "exists": False,
                "member_count": 0,
                "members": []
            })

    # -------------------------------------------------
    # 2. Collect actual directory permissions
    # -------------------------------------------------

    directories = []

    for item in expected_directories:

        directory = item["path"]
        expected_group = item["expected_group"]

        if not os.path.isdir(directory):

            directories.append({
                "path": directory,
                "exists": False,
                "expected_group": expected_group,
                "error": "Directory does not exist."
            })

            continue

        try:

            metadata = os.stat(directory)

            owner_name = pwd.getpwuid(
                metadata.st_uid
            ).pw_name

            actual_group = grp.getgrgid(
                metadata.st_gid
            ).gr_name

            permissions = stat.S_IMODE(
                metadata.st_mode
            )

            symbolic_permissions = stat.filemode(
                metadata.st_mode
            )

            directories.append({

                "path": directory,

                "exists": True,

                "owner": owner_name,

                "group": actual_group,

                "expected_group": expected_group,

                "group_matches": (
                    actual_group == expected_group
                ),

                "owner_matches": (
                    owner_name == "root"
                ),

                "permissions_octal": format(
                    permissions, "04o"
                ),

                "permissions_symbolic": (
                    symbolic_permissions
                ),

                "mode_770_matches": (
                    permissions & 0o777 == 0o770
                ),

                "setgid_enabled": (
                    bool(metadata.st_mode & stat.S_ISGID)
                )

            })

        except (OSError, KeyError) as error:

            directories.append({

                "path": directory,

                "exists": True,

                "expected_group": expected_group,

                "error": str(error)
            })

    return jsonify({

        "ok": True,

        "groups": groups,

        "directories": directories

    })
# =====================================================
# START APPLICATION
# Keep this section at the very bottom of the file.
# =====================================================

@app.route("/api/audit", methods=["GET"])
def audit_info():
    project_dir = os.path.dirname(
        os.path.dirname(os.path.abspath(__file__))
    )

    script_path = os.path.join(
        project_dir,
        "member4-testing",
        "run_test.sh"
    )

    if not os.path.isfile(script_path):
        return jsonify({
            "ok": False,
            "error": "System audit script was not found."
        }), 404

    try:
        result = subprocess.run(
            ["bash", script_path],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=20
        )

        return jsonify({
            "ok": result.returncode == 0,
            "returncode": result.returncode,
            "output": result.stdout.strip(),
            "error": result.stderr.strip()
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            "ok": False,
            "error": "System audit timed out."
        }), 504

    except Exception as e:
        return jsonify({
            "ok": False,
            "error": str(e)
        }), 500

if __name__ == "__main__":

    app.run(

        host="127.0.0.1",

        port=5000,

        debug=False
    )
# ==========================================
# SYSTEM AUDIT API
# ==========================================
