################################################################################
#
# cri-o
#
################################################################################

CRIO_BIN_VERSION = v1.19.0
CRIO_BIN_COMMIT = 99c925bebdd9e392f2d575e25f2e6a1082e6c232
CRIO_BIN_SITE = https://github.com/cri-o/cri-o/archive
CRIO_BIN_SOURCE = $(CRIO_BIN_VERSION).tar.gz
CRIO_BIN_DEPENDENCIES = host-go libgpgme
CRIO_BIN_GO_ENV = \
	CGO_ENABLED=1 \
	GO111MODULE=off

define CRIO_BIN_USERS
	- -1 crio-admin -1 - - - - -
	- -1 crio       -1 - - - - -
endef

define CRIO_BIN_BUILD_CMDS
	mkdir -p $(@D)/bin
	$(GO_TARGET_ENV) $(CRIO_BIN_GO_ENV) $(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) COMMIT_NO=$(CRIO_BIN_COMMIT) PREFIX=/usr binaries
endef

define CRIO_BIN_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/containers/oci/hooks.d
	mkdir -p $(TARGET_DIR)/etc/containers/oci/hooks.d

	$(INSTALL) -Dm755 \
		$(@D)/bin/crio \
		$(TARGET_DIR)/usr/bin/crio
	$(INSTALL) -Dm755 \
		$(@D)/bin/pinns \
		$(TARGET_DIR)/usr/bin/pinns
	$(INSTALL) -Dm644 \
		$(CRIO_BIN_PKGDIR)/crio.conf \
		$(TARGET_DIR)/etc/crio/crio.conf
	$(INSTALL) -Dm644 \
		$(CRIO_BIN_PKGDIR)/policy.json \
		$(TARGET_DIR)/etc/containers/policy.json
	$(INSTALL) -Dm644 \
		$(CRIO_BIN_PKGDIR)/registries.conf \
		$(TARGET_DIR)/etc/containers/registries.conf

	mkdir -p $(TARGET_DIR)/etc/sysconfig
	echo 'CRIO_OPTIONS="--log-level=debug"' > $(TARGET_DIR)/etc/sysconfig/crio
endef

define CRIO_BIN_INSTALL_INIT_SYSTEMD
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) install.systemd DESTDIR=$(TARGET_DIR) PREFIX=$(TARGET_DIR)/usr
	$(INSTALL) -Dm644 \
		$(CRIO_BIN_PKGDIR)/crio.service \
		$(TARGET_DIR)/usr/lib/systemd/system/crio.service
	$(INSTALL) -Dm644 \
		$(CRIO_BIN_PKGDIR)/crio-wipe.service \
		$(TARGET_DIR)/usr/lib/systemd/system/crio-wipe.service
	$(call link-service,crio.service)
	$(call link-service,crio-shutdown.service)
endef

$(eval $(golang-package))
