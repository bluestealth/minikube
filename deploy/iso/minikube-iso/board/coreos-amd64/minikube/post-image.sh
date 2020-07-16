#!/bin/sh

set -e

BOARD_DIR="$(dirname $0)"
GRUB2_MODULES="boot search search_label linux gzio fat squash4 part_msdos part_gpt normal biosdisk iso9660 serial"
ROOTFS_TMP_TARGET_DIR=`mktemp -d`

# Create 386 Bios Grub2 Bootloader
${HOST_DIR}/usr/bin/grub-mkimage \
        -d ${HOST_DIR}/lib/grub/i386-pc \
        -O i386-pc \
        -o ${BINARIES_DIR}/grub-i386-pc.img \
        -p "(cd)/boot/grub" \
        ${GRUB2_MODULES}

cat ${HOST_DIR}/lib/grub/i386-pc/cdboot.img ${BINARIES_DIR}/grub-i386-pc.img > ${BINARIES_DIR}/grub-eltorito.img

# Create EFI Bootloader Partition vfat image
support/scripts/genimage.sh -c "${BINARIES_DIR}/genimage-efi.cfg"

# Copy Grub2 BIOS Config
mkdir -p ${ROOTFS_TMP_TARGET_DIR}/boot/grub
cp ${BOARD_DIR}/grub.cfg ${ROOTFS_TMP_TARGET_DIR}/boot/grub
cp ${BINARIES_DIR}/grub-eltorito.img ${ROOTFS_TMP_TARGET_DIR}/boot/grub/grub.img

# Copy Grub2 EFI Config
mkdir -p ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT
cp ${BINARIES_DIR}/efi-part/EFI/BOOT/bootx64.efi  ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT/bootx64.efi
cp ${BOARD_DIR}/grub.cfg ${ROOTFS_TMP_TARGET_DIR}/EFI/BOOT/grub.cfg

# Copy Kernal and Initramfs
cp ${BINARIES_DIR}/bzImage ${ROOTFS_TMP_TARGET_DIR}/bzImage
cp ${BINARIES_DIR}/rootfs.cpio.gz ${ROOTFS_TMP_TARGET_DIR}/initrd

# Create CD Image
xorriso -as mkisofs -V 'MINIKUBE' -o ${BINARIES_DIR}/rootfs.iso9660 \
-J -R -boot-load-size 4 -boot-info-table -no-emul-boot \
-e --interval:appended_partition_2:all:: \
-append_partition 2 0xef ${BINARIES_DIR}/grub-efi.img \
-b boot/grub/grub.img \
${ROOTFS_TMP_TARGET_DIR}

# Cleanup
rm -rf ${ROOTFS_TMP_TARGET_DIR}