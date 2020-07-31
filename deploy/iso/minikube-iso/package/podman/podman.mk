PODMAN_VERSION = v2.2.1
PODMAN_COMMIT = a0d478edea7f775b7ce32f8eb1a01e75374486cb
PODMAN_SITE = https://github.com/containers/podman/archive
PODMAN_SOURCE = $(PODMAN_VERSION).tar.gz
PODMAN_LICENSE = Apache-2.0
PODMAN_LICENSE_FILES = LICENSE
PODMAN_TAGS = exclude_graphdriver_devicemapper
PODMAN_DEPENDENCIES = host-go
PODMAN_BIN_ENV = \
	$(GO_TARGET_ENV) \
	CGO_ENABLED=1 \
	GOPATH="$(PODMAN_GOPATH)" \
	GOBIN="$(PODMAN_GOPATH)/bin" \
	PATH=$(PODMAN_GOPATH)/bin:$(BR_PATH)


define PODMAN_USERS
	- -1 podman -1 - - - - -
endef

PODMAN_BUILD_TARGETS = cmd/podman
LIBPOD = github.com/containers/podman/v2/libpod
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

define PODMAN_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 644 \
			$(@D)/contrib/systemd/system/podman.service \
			$(TARGET_DIR)/usr/lib/systemd/system/podman.service
	$(INSTALL) -D -m 644 \
			$(@D)/contrib/systemd/system/podman.socket \
			$(TARGET_DIR)/usr/lib/systemd/system/podman.socket

	# Allow running podman-remote as a user in the group "podman"
	$(INSTALL) -D -m 644 \
			$(PODMAN_PKGDIR)/override.conf \
			$(TARGET_DIR)/usr/lib/systemd/system/podman.socket.d/override.conf
	$(INSTALL) -D -m 644 \
			$(PODMAN_PKGDIR)/podman.conf \
			$(TARGET_DIR)/usr/lib/tmpfiles.d/podman.conf
endef

$(eval $(golang-package))
