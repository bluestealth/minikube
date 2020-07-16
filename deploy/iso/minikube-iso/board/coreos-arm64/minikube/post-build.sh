#!/bin/sh

BOARD_DIR="$(dirname $0)"

cp -f ${BOARD_DIR}/grub.cfg ${BINARIES_DIR}/efi-part/EFI/BOOT/grub.cfg
cp -f ${BOARD_DIR}/genimage-efi.cfg ${BINARIES_DIR}/genimage-efi.cfg