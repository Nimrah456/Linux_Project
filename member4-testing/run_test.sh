#!/bin/bash

# Member 4: System Audit and Validation

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR" || exit 1

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "=========================================="
echo " LINUX SYSTEM AUDIT"
echo "=========================================="

# 1. Testing directory
echo ""
echo "1. Checking testing directory..."

if mkdir -p testing && [ -d testing ]; then
    pass "Testing directory exists"
else
    fail "Unable to create testing directory"
fi

# 2. Student accounts
echo ""
echo "2. Checking student accounts..."

STUDENT_COUNT=$(getent passwd | awk -F: \
    '$1 ~ /^student[0-9]+$/ {count++} END {print count+0}')

echo "Student accounts found: $STUDENT_COUNT"

if [ "$STUDENT_COUNT" -eq 100 ]; then
    pass "All 100 student accounts are present"
else
    fail "Expected 100 student accounts; found $STUDENT_COUNT"
fi

# 3. Required groups
echo ""
echo "3. Checking class groups..."

for GROUP in class_a class_b class_c; do
    if getent group "$GROUP" >/dev/null 2>&1; then
        pass "Group $GROUP exists"
    else
        fail "Group $GROUP is missing"
    fi
done

# 4. Shared folders and permissions
echo ""
echo "4. Checking shared directories..."

for ENTRY in "shared1 class_a" \
             "shared2 class_b" \
             "shared3 class_c"; do

    set -- $ENTRY

    DIR_NAME="$1"
    EXPECTED_GROUP="$2"
    DIR_PATH="/data/$DIR_NAME"

    if [ ! -d "$DIR_PATH" ]; then
        fail "$DIR_PATH does not exist"
        continue
    fi

    INFO=$(stat -c '%U %G %a' "$DIR_PATH")
    read -r OWNER GROUP MODE <<< "$INFO"

    echo "$DIR_PATH: owner=$OWNER group=$GROUP mode=$MODE"

    if [ "$OWNER" = "root" ] &&
       [ "$GROUP" = "$EXPECTED_GROUP" ] &&
       [ "$MODE" = "2770" ]; then

        pass "$DIR_PATH ownership and permissions are correct"
    else
        fail "$DIR_PATH ownership or permissions need checking"
    fi
done

# 5. Firewall
echo ""
echo "5. Checking firewall..."

if systemctl is-active --quiet ufw; then
    pass "UFW firewall service is active"
else
    fail "UFW firewall service is not active"
fi

# 6. SSH service
echo ""
echo "6. Checking SSH service..."

if systemctl is-active --quiet ssh; then
    pass "SSH service is active"
else
    fail "SSH service is not active"
fi

# 7. Network and DNS resolution
echo ""
echo "7. Checking network name resolution..."

if getent hosts example.com >/dev/null 2>&1; then
    pass "example.com resolves successfully"
else
    fail "Unable to resolve example.com"
fi

# Final results
echo ""
echo "=========================================="
echo " AUDIT SUMMARY"
echo "=========================================="
echo "Checks passed: $PASS_COUNT"
echo "Checks failed: $FAIL_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "RESULT: ALL CHECKS PASSED"
    exit 0
else
    echo "RESULT: SOME CHECKS FAILED"
    exit 1
fi
