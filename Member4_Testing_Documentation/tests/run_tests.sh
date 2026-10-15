#!/bin/bash
# OWNER: Member 4 - Testing, Documentation & Presentation Lead
set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
errors=0

echo "=== 1. Bash syntax checks ==="
for file in "$PROJECT_ROOT/main.sh" "$PROJECT_ROOT"/modules/*.sh; do
    if [[ ! -f "$file" ]]; then
        echo "[FAIL] Missing file: $file"; errors=$((errors + 1)); continue
    fi
    if bash -n "$file"; then
        echo "[OK] Syntax valid: ${file#"$PROJECT_ROOT"/}"
    else
        echo "[FAIL] Syntax error: ${file#"$PROJECT_ROOT"/}"; errors=$((errors + 1))
    fi
done

echo "=== 2. Menu functions are defined ==="
for pair in accounts:menu_accounts environment:menu_environment system_admin:menu_sysadmin \
            storage:menu_storage automation:menu_automation security:menu_security monitor:menu_monitor; do
    mod="${pair%%:*}"; fn="${pair##*:}"
    if grep -q "^$fn()" "$PROJECT_ROOT/modules/$mod.sh"; then
        echo "[OK] $fn found in $mod.sh"
    else
        echo "[FAIL] $fn missing in $mod.sh"; errors=$((errors + 1))
    fi
done

echo "=== 3. Config files ==="
for cfg in config/students.csv config/packages.txt; do
    if [[ -s "$PROJECT_ROOT/$cfg" ]]; then
        echo "[OK] $cfg present and non-empty"
    else
        echo "[FAIL] $cfg missing or empty"; errors=$((errors + 1))
    fi
done

echo "=== 4. Username validation logic ==="
for u in john01 jane_02 alex-03; do
    [[ "$u" =~ ^[a-z_][a-z0-9_-]*$ ]] && echo "[OK] accepted: $u" || { echo "[FAIL] rejected valid: $u"; errors=$((errors + 1)); }
done
for u in 'Bad User' '1abc' 'x;rm' ''; do
    [[ "$u" =~ ^[a-z_][a-z0-9_-]*$ ]] && { echo "[FAIL] accepted invalid: '$u'"; errors=$((errors + 1)); } || echo "[OK] rejected: '$u'"
done

echo "=== 5. Backup / restore round trip ==="
tmp="$(mktemp -d)"
mkdir -p "$tmp/shared_labs" "$tmp/config"
echo "data" > "$tmp/shared_labs/f.txt"; echo "cfg" > "$tmp/config/c.txt"
if (cd "$tmp" && tar -czf b.tar.gz shared_labs config && tar -tzf b.tar.gz >/dev/null && rm -rf shared_labs && tar -xzf b.tar.gz && [[ -f shared_labs/f.txt ]]); then
    echo "[OK] Backup created, verified and restored"
else
    echo "[FAIL] Backup round trip failed"; errors=$((errors + 1))
fi
rm -rf "$tmp"

echo "=== 6. Cron entry duplicate check ==="
line='0 2 * * * /bin/bash "/x/main.sh" --cron-cleanup'
if echo "$line" | grep -Fq -- "--cron-cleanup"; then
    echo "[OK] Duplicate detection matches quoted cron line"
else
    echo "[FAIL] Duplicate detection broken"; errors=$((errors + 1))
fi

echo "=========================================="
if [[ "$errors" -eq 0 ]]; then
    echo "[OK] All tests passed."; exit 0
fi
echo "[FAIL] $errors test(s) failed."; exit 1
