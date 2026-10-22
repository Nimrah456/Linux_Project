// ==========================================
// HELPER FUNCTIONS
// ==========================================

function createElement(tag, className, text) {
    const element = document.createElement(tag);

    if (className) {
        element.className = className;
    }

    if (text !== undefined) {
        element.textContent = text;
    }

    return element;
}


async function postJSON(url, data) {
    const response = await fetch(url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(data)
    });

    const result = await response.json();

    if (!response.ok || !result.ok) {
        throw new Error(
            result.error || "The operation failed."
        );
    }

    return result;
}


// ==========================================
// UPDATE OVERVIEW CARDS
// ==========================================

function updateOverviewCard(index, headingText, detailText) {
    const cards = document.querySelectorAll(
        ".stats-grid .stat-card"
    );

    const card = cards[index];

    if (!card) return;

    const heading = card.querySelector("h3");
    const detail = card.querySelector("small");

    if (heading) heading.textContent = headingText;
    if (detail) detail.textContent = detailText;
}


// ==========================================
// SYSTEM OVERVIEW
// ==========================================

async function loadSystemInfo() {
    const studentCount =
        document.getElementById("student-count");

    const studentDetail =
        document.getElementById("student-detail");

    const storageFree =
        document.getElementById("storage-free");

    const storageDetail =
        document.getElementById("storage-detail");

    const serverDetails =
        document.getElementById("server-details");

    try {
        const response = await fetch("/api/system", {
            cache: "no-store"
        });

        if (!response.ok) {
            throw new Error(
                "Unable to retrieve system information."
            );
        }

        const data = await response.json();

        studentCount.textContent =
            data.student_accounts.toLocaleString();

        studentDetail.textContent =
            "Accounts found on this Linux server";

        storageFree.textContent =
            `${data.root_disk.free_gb} GB free`;

        storageDetail.textContent =
            `of ${data.root_disk.total_gb} GB on the root filesystem`;

        serverDetails.textContent =
            `${data.operating_system} | ${data.hostname}`;

    } catch (error) {
        console.error("System information error:", error);

        studentCount.textContent = "Unavailable";
        studentDetail.textContent =
            "Unable to retrieve accounts";

        storageFree.textContent = "Unavailable";
        storageDetail.textContent =
            "Unable to retrieve disk information";

        serverDetails.textContent =
            "Unable to connect to the Linux server";
    }
}


// ==========================================
// USER MANAGEMENT
// ==========================================

async function loadUsers() {
    const panel = document.querySelector("#users .panel");

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "Student accounts registered on this Linux server."
        )
    );

    const toolbar = createElement("div", "panel-toolbar");

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Users"
    );

    refreshButton.type = "button";
    refreshButton.addEventListener("click", loadUsers);

    toolbar.appendChild(refreshButton);

    const status = createElement(
        "p",
        "notice",
        "Loading student accounts..."
    );

    panel.append(toolbar, status);

    refreshButton.disabled = true;

    try {
        const response = await fetch("/api/users", {
            cache: "no-store"
        });

        if (!response.ok) {
            throw new Error(
                "Unable to retrieve student accounts."
            );
        }

        const data = await response.json();

        status.textContent =
            `Retrieved ${data.count} student accounts.`;

        const wrapper = createElement(
            "div",
            "data-table-wrap"
        );

        const table = createElement(
            "table",
            "data-table"
        );

        const thead = document.createElement("thead");
        const headerRow = document.createElement("tr");

        [
            "Username",
            "Class Group",
            "Home Directory",
            "Login Shell"
        ].forEach(heading => {
            headerRow.appendChild(
                createElement("th", "", heading)
            );
        });

        thead.appendChild(headerRow);

        const tbody = document.createElement("tbody");

        data.users.forEach(user => {
            const row = document.createElement("tr");

            [
                user.username,
                user.class_group,
                user.home_directory,
                user.login_shell
            ].forEach(value => {
                row.appendChild(
                    createElement("td", "", value)
                );
            });

            tbody.appendChild(row);
        });

        table.append(thead, tbody);
        wrapper.appendChild(table);
        panel.appendChild(wrapper);

    } catch (error) {
        console.error("User information error:", error);

        status.textContent =
            "Unable to retrieve student accounts.";

    } finally {
        refreshButton.disabled = false;
    }
}


// ==========================================
// STORAGE MANAGEMENT
// ==========================================

async function loadStorage() {
    const panel = document.querySelector("#storage .panel");

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "Read-only information about Linux disks, LVM volumes, filesystems and disk usage."
        )
    );

    const toolbar = createElement("div", "panel-toolbar");

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Storage Information"
    );

    refreshButton.type = "button";
    refreshButton.addEventListener("click", loadStorage);

    toolbar.appendChild(refreshButton);

    const status = createElement(
        "p",
        "notice",
        "Loading storage information..."
    );

    const resultsContainer = createElement(
        "div",
        "storage-results"
    );

    panel.append(toolbar, status, resultsContainer);

    refreshButton.disabled = true;

    try {
        const response = await fetch("/api/storage", {
            cache: "no-store"
        });

        if (!response.ok) {
            throw new Error(
                "Unable to retrieve storage information."
            );
        }

        const data = await response.json();

        const successfulChecks = data.checks.filter(
            check => check.ok
        ).length;

        status.textContent =
            `Completed ${successfulChecks} of ${data.checks.length} storage checks.`;

        data.checks.forEach(check => {
            const section = createElement(
                "div",
                "storage-result"
            );

            section.appendChild(
                createElement("h3", "", check.title)
            );

            section.appendChild(
                createElement(
                    "p",
                    "command-label",
                    `$ ${check.command}`
                )
            );

            const output = check.ok
                ? (check.output || "No output returned.")
                : [check.error, check.output]
                    .filter(Boolean)
                    .join("\n");

            section.appendChild(
                createElement(
                    "pre",
                    check.ok
                        ? "command-output"
                        : "command-error",
                    output
                )
            );

            resultsContainer.appendChild(section);
        });

    } catch (error) {
        console.error("Storage information error:", error);

        status.textContent =
            "Unable to retrieve storage information.";

    } finally {
        refreshButton.disabled = false;
    }
}


// ==========================================
// BACKUP & RECOVERY
// ==========================================

function formatBytes(bytes) {
    if (bytes < 1024) {
        return `${bytes} B`;
    }

    const units = ["KB", "MB", "GB", "TB"];

    let size = bytes / 1024;
    let index = 0;

    while (size >= 1024 && index < units.length - 1) {
        size /= 1024;
        index++;
    }

    return `${size.toFixed(2)} ${units[index]}`;
}


async function loadBackups(message = "") {
    const panel = document.querySelector("#backups .panel");

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "View existing backup archives, inspect their contents, or create a new backup."
        )
    );

    const toolbar = createElement("div", "panel-toolbar");

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Backups"
    );

    const createButton = createElement(
        "button",
        "",
        "Create Backup"
    );

    refreshButton.type = "button";
    createButton.type = "button";

    toolbar.append(refreshButton, createButton);

    const status = createElement(
        "p",
        "notice",
        message || "Loading backups..."
    );

    const wrapper = createElement(
        "div",
        "data-table-wrap"
    );

    const table = createElement("table", "data-table");
    const thead = document.createElement("thead");
    const headerRow = document.createElement("tr");

    [
        "Backup Archive",
        "Size",
        "Last Modified",
        "Action"
    ].forEach(heading => {
        headerRow.appendChild(
            createElement("th", "", heading)
        );
    });

    thead.appendChild(headerRow);

    const tbody = document.createElement("tbody");

    table.append(thead, tbody);
    wrapper.appendChild(table);

    const inspectionHeading = createElement(
        "h3",
        "backup-inspection-heading",
        ""
    );

    const inspectionOutput = createElement(
        "pre",
        "command-output backup-inspection",
        ""
    );

    inspectionHeading.hidden = true;
    inspectionOutput.hidden = true;

    panel.append(
        toolbar,
        status,
        wrapper,
        inspectionHeading,
        inspectionOutput
    );

    refreshButton.disabled = true;
    createButton.disabled = true;

    refreshButton.addEventListener("click", () => {
        loadBackups();
    });

    createButton.addEventListener("click", async () => {
        const confirmed = window.confirm(
            "Create a new backup of the mounted shared directories?"
        );

        if (!confirmed) return;

        refreshButton.disabled = true;
        createButton.disabled = true;

        status.textContent =
            "Creating and verifying the backup...";

        try {
            const result = await postJSON(
                "/api/backups/create",
                { confirm: true }
            );

            await loadBackups(result.message);

        } catch (error) {
            console.error("Backup creation error:", error);

            status.textContent =
                `Backup failed: ${error.message}`;

            refreshButton.disabled = false;
            createButton.disabled = false;
        }
    });

    try {
        const response = await fetch("/api/backups", {
            cache: "no-store"
        });

        const data = await response.json();

        if (!response.ok || !data.ok) {
            throw new Error(
                data.error || "Unable to list backups."
            );
        }

        updateOverviewCard(
            2,
            `${data.count} archive${data.count === 1 ? "" : "s"}`,
            "Backup archives found in /backup"
        );

        if (!message) {
            status.textContent =
                `Found ${data.count} backup archives in /backup.`;
        }

        data.backups.forEach(backup => {
            const row = document.createElement("tr");

            row.appendChild(
                createElement("td", "", backup.filename)
            );

            row.appendChild(
                createElement(
                    "td",
                    "",
                    formatBytes(backup.size_bytes)
                )
            );

            row.appendChild(
                createElement("td", "", backup.modified)
            );

            const actionCell = document.createElement("td");

            const inspectButton = createElement(
                "button",
                "",
                "Inspect"
            );

            inspectButton.type = "button";

            inspectButton.addEventListener("click", async () => {
                inspectButton.disabled = true;

                inspectionHeading.hidden = false;
                inspectionOutput.hidden = false;

                inspectionHeading.textContent =
                    `Contents of ${backup.filename}`;

                inspectionOutput.textContent =
                    "Inspecting archive...";

                try {
                    const result = await postJSON(
                        "/api/backups/inspect",
                        { filename: backup.filename }
                    );

                    inspectionOutput.textContent =
                        result.output;

                } catch (error) {
                    inspectionOutput.textContent =
                        `Inspection failed: ${error.message}`;

                } finally {
                    inspectButton.disabled = false;
                }
            });

            actionCell.appendChild(inspectButton);
            row.appendChild(actionCell);
            tbody.appendChild(row);
        });

        if (data.count === 0) {
            const row = document.createElement("tr");

            row.appendChild(
                createElement(
                    "td",
                    "",
                    "No matching backup archives found."
                )
            );

            tbody.appendChild(row);
        }

    } catch (error) {
        console.error("Backup listing error:", error);

        status.textContent =
            `Unable to load backups: ${error.message}`;

        updateOverviewCard(
            2,
            "Unavailable",
            "Unable to retrieve backup information"
        );

    } finally {
        refreshButton.disabled = false;
        createButton.disabled = false;
    }
}


// ==========================================
// FIREWALL & SECURITY
// ==========================================

async function loadSecurity() {
    const panel = document.querySelector("#security .panel");

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "Inspect the actual UFW firewall configuration and relevant service status. This page does not change firewall rules."
        )
    );

    const toolbar = createElement("div", "panel-toolbar");

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Security Status"
    );

    refreshButton.type = "button";
    refreshButton.addEventListener("click", loadSecurity);

    toolbar.appendChild(refreshButton);

    const status = createElement(
        "p",
        "notice",
        "Checking firewall status..."
    );

    const outputHeading = createElement(
        "h3",
        "",
        "Security Command Output"
    );

    const output = createElement(
        "pre",
        "command-output",
        ""
    );

    panel.append(
        toolbar,
        status,
        outputHeading,
        output
    );

    refreshButton.disabled = true;

    try {
        const response = await fetch("/api/security", {
            cache: "no-store"
        });

        const data = await response.json();

        if (!response.ok || !data.ok) {
            throw new Error(
                data.error || "Unable to retrieve security information."
            );
        }

        const firewallStatus =
            String(data.firewall_status || "unknown").toLowerCase();

        const readableStatus = {
            active: "ACTIVE",
            inactive: "INACTIVE",
            unknown: "UNKNOWN"
        };

        status.textContent =
            `UFW firewall status: ${
                readableStatus[firewallStatus] || "UNKNOWN"
            }`;

        output.textContent =
            data.output || "No command output was returned.";

        updateOverviewCard(
            3,
            readableStatus[firewallStatus] || "UNKNOWN",
            "Status reported by UFW"
        );

    } catch (error) {
        console.error("Security status error:", error);

        status.textContent =
            `Unable to retrieve security status: ${error.message}`;

        output.textContent =
            "The firewall configuration could not be retrieved.";

        updateOverviewCard(
            3,
            "Unavailable",
            "Unable to retrieve firewall status"
        );

    } finally {
        refreshButton.disabled = false;
    }
}

// ==========================================
// CLEANUP AND AUTOMATION
// ==========================================

async function loadAutomation() {

    const panel = document.querySelector(
        "#automation .panel"
    );

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "View cron schedules, service status, and cleanup and backup scripts."
        )
    );

    const toolbar = createElement(
        "div",
        "panel-toolbar"
    );

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Automation Status"
    );

    refreshButton.type = "button";

    const status = createElement(
        "p",
        "notice",
        "Loading automation information..."
    );

    const results = createElement(
        "div",
        "automation-results"
    );

    toolbar.appendChild(refreshButton);

    panel.append(
        toolbar,
        status,
        results
    );

    refreshButton.addEventListener(
        "click",
        loadAutomation
    );

    refreshButton.disabled = true;

    try {

        const response = await fetch(
            "/api/automation",
            { cache: "no-store" }
        );

        const data = await response.json();

        if (!response.ok || !data.ok) {
            throw new Error(
                data.error || "Unable to retrieve automation information."
            );
        }

        status.textContent =
            "Automation information retrieved.";

        data.sections.forEach(function (item) {

            const section = createElement(
                "div",
                "storage-result"
            );

            section.appendChild(
                createElement(
                    "h3",
                    "",
                    item.title
                )
            );

            section.appendChild(
                createElement(
                    "p",
                    "command-label",
                    item.source
                )
            );

            section.appendChild(
                createElement(
                    "pre",
                    item.ok
                        ? "command-output"
                        : "command-error",
                    item.output
                )
            );

            results.appendChild(section);

        });

    } catch (error) {

        console.error(
            "Automation error:",
            error
        );

        status.textContent =
            "Unable to load automation information: " +
            error.message;

    } finally {

        refreshButton.disabled = false;
    }
}
// ==========================================
// PERMISSIONS AND ACCESS CONTROL
// ==========================================

async function loadPermissions() {

    const panel = document.querySelector(
        "#permissions .panel"
    );

    if (!panel) return;

    panel.replaceChildren();

    panel.appendChild(
        createElement(
            "p",
            "",
            "Actual class groups, shared directory ownership, and Linux permissions."
        )
    );

    const toolbar = createElement(
        "div",
        "panel-toolbar"
    );

    const refreshButton = createElement(
        "button",
        "",
        "Refresh Permissions"
    );

    refreshButton.type = "button";

    toolbar.appendChild(refreshButton);

    const status = createElement(
        "p",
        "notice",
        "Loading permission information..."
    );

    const results = createElement(
        "div",
        "permissions-results"
    );

    panel.append(
        toolbar,
        status,
        results
    );

    refreshButton.addEventListener(
        "click",
        loadPermissions
    );

    refreshButton.disabled = true;

    try {

        const response = await fetch(
            "/api/permissions",
            { cache: "no-store" }
        );

        const data = await response.json();

        if (!response.ok || !data.ok) {

            throw new Error(
                data.error ||
                "Unable to retrieve permission information."
            );
        }

        status.textContent =
            "Linux permission information retrieved successfully.";

        // ---------------------------------------
        // Display class groups
        // ---------------------------------------

        results.appendChild(
            createElement(
                "h3",
                "",
                "Class Groups"
            )
        );

        const groupTable = createElement(
            "table",
            "data-table"
        );

        const groupHead = document.createElement("thead");
        const groupHeader = document.createElement("tr");

        [
            "Group",
            "GID",
            "Status",
            "Member Count"
        ].forEach(heading => {

            groupHeader.appendChild(
                createElement("th", "", heading)
            );

        });

        groupHead.appendChild(groupHeader);

        const groupBody = document.createElement("tbody");

        data.groups.forEach(group => {

            const row = document.createElement("tr");

            [
                group.name,
                group.gid ?? "Unavailable",
                group.exists ? "Exists" : "Missing",
                group.member_count
            ].forEach(value => {

                row.appendChild(
                    createElement("td", "", String(value))
                );

            });

            groupBody.appendChild(row);

        });

        groupTable.append(groupHead, groupBody);

        const groupWrapper = createElement(
            "div",
            "data-table-wrap"
        );

        groupWrapper.appendChild(groupTable);

        results.appendChild(groupWrapper);

        // ---------------------------------------
        // Display shared directory permissions
        // ---------------------------------------

        results.appendChild(
            createElement(
                "h3",
                "",
                "Shared Directory Permissions"
            )
        );

        const directoryTable = createElement(
            "table",
            "data-table"
        );

        const directoryHead = document.createElement("thead");
        const directoryHeader = document.createElement("tr");

        [
            "Directory",
            "Owner",
            "Actual Group",
            "Expected Group",
            "Permissions",
            "Configuration"
        ].forEach(heading => {

            directoryHeader.appendChild(
                createElement("th", "", heading)
            );

        });

        directoryHead.appendChild(directoryHeader);

        const directoryBody = document.createElement("tbody");

        data.directories.forEach(directory => {

            const row = document.createElement("tr");

            let configuration = "Check required";

            if (!directory.exists) {

                configuration = "Missing";

            } else if (directory.error) {

                configuration = "Unable to inspect";

            } else if (
                directory.owner_matches &&
                directory.group_matches &&
                directory.mode_770_matches
            ) {

                configuration = "Expected ownership and access bits";

            } else {

                configuration = "Review configuration";

            }

            [
                directory.path,
                directory.owner || "Unavailable",
                directory.group || "Unavailable",
                directory.expected_group,
                directory.permissions_octal
                    ? `${directory.permissions_symbolic} (${directory.permissions_octal})`
                    : "Unavailable",
                configuration
            ].forEach(value => {

                row.appendChild(
                    createElement("td", "", String(value))
                );

            });

            directoryBody.appendChild(row);

        });

        directoryTable.append(directoryHead, directoryBody);

        const directoryWrapper = createElement(
            "div",
            "data-table-wrap"
        );

        directoryWrapper.appendChild(directoryTable);

        results.appendChild(directoryWrapper);

        // ---------------------------------------
        // Display setgid status
        // ---------------------------------------

        results.appendChild(
            createElement(
                "h3",
                "",
                "Shared Directory Group Inheritance"
            )
        );

        data.directories.forEach(directory => {

            if (!directory.exists || directory.error) return;

            results.appendChild(
                createElement(
                    "p",
                    "",
                    `${directory.path}: setgid ${
                        directory.setgid_enabled
                            ? "enabled"
                            : "not enabled"
                    }.`
                )
            );

        });

    } catch (error) {

        console.error("Permissions error:", error);

        status.textContent =
            `Unable to load permissions: ${error.message}`;

    } finally {

        refreshButton.disabled = false;
    }
}
// ==========================================
// INITIALISE DASHBOARD
// ==========================================

// ==========================================
// INITIALISE DASHBOARD
// ==========================================


// ==========================================
// SYSTEM AUDIT
// ==========================================

async function runSystemAudit() {
    const button = document.getElementById("run-audit-button");
    const status = document.getElementById("audit-status");
    const output = document.getElementById("audit-output");

    if (!button || !status || !output) {
        return;
    }

    button.disabled = true;
    button.textContent = "Running System Audit...";
    status.textContent = "Audit is running...";
    output.textContent = "Please wait...";

    try {
        const response = await fetch("/api/audit", {
            cache: "no-store"
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(
                data.error || `Request failed: ${response.status}`
            );
        }

        status.textContent = data.ok
            ? "Audit passed successfully!"
            : `Audit failed. Exit code: ${data.returncode}`;

        output.textContent = data.output || "No output returned.";

        if (data.error) {
            output.textContent +=
                "\\n\\nError details:\\n" + data.error;
        }

    } catch (error) {
        status.textContent =
            "Unable to run audit: " + error.message;

        output.textContent = "";

    } finally {
        button.disabled = false;
        button.textContent = "Run System Audit";
    }
}

function initializeDashboard() {
    loadSystemInfo();
    loadUsers();
    loadStorage();
    loadBackups();
    loadSecurity();
    loadAutomation();
    loadPermissions();

    const auditButton = document.getElementById("run-audit-button");

    if (auditButton) {
        auditButton.addEventListener("click", runSystemAudit);
    }
}

if (document.readyState === "loading") {
    document.addEventListener(
        "DOMContentLoaded",
        initializeDashboard,
        { once: true }
    );
} else {
    initializeDashboard();
}
