#!/bin/bash
# Member 2: Storage Management (LVM Setup)

echo "Initializing Physical Volume on /dev/sdb..."
pvcreate /dev/sdb

echo "Creating Volume Group 'lab_vg'..."
vgcreate lab_vg /dev/sdb

echo "Creating Logical Volumes..."
lvcreate -n shared1 -L 4G lab_vg
lvcreate -n shared2 -L 4G lab_vg
lvcreate -n shared3 -L 4G lab_vg

echo "Formatting volumes to ext4..."
mkfs.ext4 /dev/lab_vg/shared1
mkfs.ext4 /dev/lab_vg/shared2
mkfs.ext4 /dev/lab_vg/shared3

echo "Mounting volumes..."
mount /dev/lab_vg/shared1 /data/shared1
mount /dev/lab_vg/shared2 /data/shared2
mount /dev/lab_vg/shared3 /data/shared3

echo "Storage setup complete. Current block layout:"
lsblk
