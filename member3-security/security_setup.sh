#!/bin/bash
# security_setup.sh - Member 3
# Enables ufw, allows SSH (22), denies all other incoming traffic

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo ./security_setup.sh)"; exit 1
fi

apt-get install -y ufw          # no-op if already installed

ufw default deny incoming       # block everything inbound by default
ufw default allow outgoing      # let the server reach the internet
ufw allow 22/tcp                # allow SSH BEFORE enabling the firewall
ufw --force enable              # enable without the y/n prompt

echo "=== Firewall status ==="
ufw status verbose
