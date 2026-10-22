#!/usr/bin/env bash

set -u

# This helper only displays security information.
# It does not change firewall rules.

if [[ $# -ne 0 ]]; then
    echo "ERROR: This helper accepts no arguments." >&2
    exit 2
fi

echo "=== FIREWALL CONFIGURATION ==="

if ! command -v ufw >/dev/null 2>&1; then
    echo "ERROR: UFW is not installed." >&2
    exit 1
fi

if ! ufw status verbose; then
    echo "ERROR: Unable to read UFW status." >&2
    exit 1
fi

echo
echo "=== UFW SERVICE STATUS ==="

systemctl is-active ufw 2>&1 || true

echo
echo "=== UFW ENABLED AT BOOT ==="

systemctl is-enabled ufw 2>&1 || true

echo
echo "=== SSH SERVICE STATUS ==="

systemctl is-active ssh 2>&1 || true
