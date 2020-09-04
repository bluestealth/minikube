PODMAN_DUMMY = DUMMY
PODMAN_VERSION = v2.0.5
PODMAN_COMMIT = 776abc52106ec7652ced6dbc0869020123ed393d
PODMAN_SITE = https://github.com/containers/podman/archive
PODMAN_SOURCE = $(PODMAN_VERSION).tar.gz
PODMAN_LICENSE = Apache-2.0
PODMAN_LICENSE_FILES = LICENSE
PODMAN_TAGS = exclude_graphdriver_devicemapper
PODMAN_DEPENDENCIES = host-go
PODMAN_BUILD_TARGETS = cmd/podman
LIBPOD = github.com/containers/libpod/libpod
PODMAN_LDFLAGS = \
		-X $(LIBPOD)/define.gitCommit=$(PODMAN_COMMIT) \
		-X $(LIBPOD)/define.buildInfo=$(shell date "+%s") \
		-X $(LIBPOD)/config._installPrefix=/usr \
		-X $(LIBPOD)/config._etcDir=/etc
PODMAN_BUILD_OPTS = -mod=vendor -gcflags "all=-trimpath=$(@)" -asmflags "all=-trimpath=$(@)"
PODMAN_GO_ENV = \
	CGO_ENABLED=1   \
	GO111MODULE=on

ifneq ($(BR2_PACKAGE_BTRFS_PROGS),y)
PODMAN_TAGS += exclude_graphdriver_btrfs btrfs_noversion
else
PODMAN_DEPENDENCIES += btrfs-progs
endif
ifeq ($(BR2_INIT_SYSTEMD),y)
PODMAN_TAGS += systemd
PODMAN_DEPENDENCIES += systemd
endif
ifeq ($(BR2_PACKAGE_APPARMOR),y)
PODMAN_TAGS += apparmor
PODMAN_DEPENDENCIES += libapparmor
endif
ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
PODMAN_TAGS += selinux
PODMAN_DEPENDENCIES += libselinux
endif
ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
PODMAN_TAGS += seccomp
PODMAN_DEPENDENCIES += libseccomp
endif

define PODMAN_INSTALL_TARGET_CMDS
	$(INSTALL) -Dm755 $(@D)/bin/podman $(TARGET_DIR)/usr/bin/podman
	$(INSTALL) -d -m 755 $(TARGET_DIR)/etc/cni/net.d/
	$(INSTALL) -m 644 $(@D)/cni/87-podman-bridge.conflist $(TARGET_DIR)/etc/cni/net.d/87-podman-bridge.conflist
endef

$(eval $(golang-package))
