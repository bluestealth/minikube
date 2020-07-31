################################################################################
#
# containerd
#
################################################################################
CONTAINERD_BIN_VERSION = v1.3.6
CONTAINERD_BIN_COMMIT = be75852b8d7849474a20192f9ed1bf34fdd454f1
CONTAINERD_BIN_SITE = https://github.com/containerd/containerd/archive
CONTAINERD_BIN_SOURCE = $(CONTAINERD_BIN_VERSION).tar.gz
CONTAINERD_BIN_DEPENDENCIES = host-go libgpgme
CONTAINERD_BIN_GO_ENV = \
	CGO_ENABLED=1 \
	GO111MODULE=off \
	GOPATH=$(@D)/$(CONTAINERD_BIN_WORKSPACE) \
	GOBIN="$(@D)/$(CONTAINERD_BIN_WORKSPACE)/bin" \
	PATH=$(@D)/$(CONTAINERD_BIN_WORKSPACE)/bin:$(BR_PATH)

define CONTAINERD_BIN_USERS
	- -1 containerd-admin -1 - - - - -
	- -1 containerd       -1 - - - - -
endef

define CONTAINERD_BIN_BUILD_CMDS
	PWD=$(CONTAINERD_BIN_SRC_PATH) $(GO_TARGET_ENV) $(CONTAINERD_BIN_GO_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) VERSION=$(CONTAINERD_BIN_VERSION) REVISION=$(CONTAINERD_BIN_COMMIT) -C $(@D) binaries
endef

define CONTAINERD_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -Dm755 \
		$(@D)/bin/containerd \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -Dm755 \
		$(@D)/bin/containerd-shim \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -Dm755 \
		$(@D)/bin/containerd-shim-runc-v1 \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -Dm755 \
		$(@D)/bin/containerd-shim-runc-v2 \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -Dm755 \
		$(@D)/bin/ctr \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -Dm644 \
		$(CONTAINERD_BIN_PKGDIR)/config.toml \
		$(TARGET_DIR)/etc/containerd/config.toml
endef

define CONTAINERD_BIN_INSTALL_INIT_SYSTEMD
	$(INSTALL) -Dm644 \
		$(CONTAINERD_BIN_PKGDIR)/containerd.service \
		$(TARGET_DIR)/usr/lib/systemd/system/containerd.service
	$(INSTALL) -Dm644 \
		$(CONTAINERD_BIN_PKGDIR)/50-minikube.preset \
		$(TARGET_DIR)/usr/lib/systemd/system-preset/50-minikube.preset
endef

$(eval $(golang-package))
