# Member 2 - Storage & Backup Administrator

## Duties
Disk partitioning, file-system management, LVM configuration, backup and recovery, storage allocation, storage validation.

## Code you own
- `modules/storage.sh` - create/restore/verify backups; disk, partition, file-system and LVM overview; allocation check.

## Manual work to do in the VM (script only inspects; you perform and document)
1. Add a second virtual disk, partition it: `fdisk /dev/sdb` (or `parted`).
2. Build LVM: `pvcreate /dev/sdb1` -> `vgcreate lab_vg /dev/sdb1` -> `lvcreate -L 2G -n lab_lv lab_vg`.
3. Format and mount: `mkfs.ext4 /dev/lab_vg/lab_lv`, `mount` it on `/srv/lab`, add to `/etc/fstab`.
4. Extend the volume: `lvextend -r -L +1G /dev/lab_vg/lab_lv`.
5. Then use menu 4 -> options 4, 5, 6 to show the results.

## Demo checklist (viva)
Create a backup, verify it, delete a test file, restore, confirm the file returned; show `lsblk`, `pvs/vgs/lvs`, `df -hT`.
