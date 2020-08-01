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

# Copy Kernel and Initramfs
cp ${BINARIES_DIR}/Image ${ROOTFS_TMP_TARGET_DIR}/Image
cp ${BINARIES_DIR}/rootfs.cpio.gz ${ROOTFS_TMP_TARGET_DIR}/initrd

# Create CD Image
rm -f ${BINARIES_DIR}/rootfs.iso9660
xorriso -volid 'MINIKUBE' \
  -outdev ${BINARIES_DIR}/rootfs.iso9660 \
  -padding 0 \
  -map ${ROOTFS_TMP_TARGET_DIR} / \
  -chmod 0755 / -- \
  -boot_image any iso_mbr_part_type=0x83 \
  -boot_image any cat_path='/boot.catalog' \
  -boot_image any appended_part_as=gpt \
  -boot_image any emul_type=no_emulation \
  -append_partition 1 0xee ${BINARIES_DIR}/grub-efi.img \
  -boot_image grub efi_path=--interval:appended_partition_1:all::


# Cleanup
rm -rf ${ROOTFS_TMP_TARGET_DIR}