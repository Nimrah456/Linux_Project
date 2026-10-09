#!/bin/bash
# Member 1: SysAdmin (Folder Permissions)

echo "Ensuring shared directories exist..."
mkdir -p /data/shared1 /data/shared2 /data/shared3

echo "Setting folder ownership to student groups..."
chown root:class_a /data/shared1
chown root:class_b /data/shared2
chown root:class_c /data/shared3

echo "Setting strict access permissions (Group Read/Write, Others blocked)..."
chmod 770 /data/shared1
chmod 770 /data/shared2
chmod 770 /data/shared3

echo "Permissions applied successfully:"
ls -ld /data/shared*
