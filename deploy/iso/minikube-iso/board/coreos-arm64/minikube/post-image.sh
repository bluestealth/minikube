#!/bin/sh

set -e

BOARD_DIR="$(dirname $0)"
ROOTFS_TMP_TARGET_DIR=`mktemp -d`

# Create EFI Bootloader Partition vfat image
support/scripts/genimage.sh -c "${BINARIES_DIR}/genimage-efi.cfg"

# Copy Grub2 EFI Config
mkdir -p ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT
cp ${BINARIES_DIR}/efi-part/EFI/BOOT/bootaa64.efi  ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT/bootaa64.efi
cp ${BOARD_DIR}/grub.cfg ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT/grub.cfg

# Copy Kernal and Initramfs
cp ${BINARIES_DIR}/Image ${ROOTFS_TMP_TARGET_DIR}/Image
cp ${BINARIES_DIR}/rootfs.cpio.gz ${ROOTFS_TMP_TARGET_DIR}/initrd

# Create CD Image
xorriso -as mkisofs -V 'MINIKUBE' -o ${BINARIES_DIR}/rootfs.iso9660 \
-J -R -no-emul-boot \
-e --interval:appended_partition_2:all:: \
-append_partition 2 0xef ${BINARIES_DIR}/grub-efi.img \
${ROOTFS_TMP_TARGET_DIR}

# Cleanup
rm -rf ${ROOTFS_TMP_TARGET_DIR}