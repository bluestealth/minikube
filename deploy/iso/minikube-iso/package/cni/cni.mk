################################################################################
#
# cni
#
################################################################################

CNI_VERSION = v0.7.1
CNI_SITE = https://github.com/containernetworking/cni/archive
CNI_SOURCE = $(CNI_VERSION).tar.gz
CNI_LICENSE = Apache-2.0
CNI_LICENSE_FILES = LICENSE

CNI_DEPENDENCIES = host-go

CNI_GO_ENV = \
	CGO_ENABLED=0 \
	GO111MODULE=off

CNI_LDFLAGS = -extldflags '-static'
CNI_BUILD_TARGETS = cnitool

define CNI_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/bin/cnitool \
		$(TARGET_DIR)/opt/cni/bin/cnitool

	ln -sf \
		../../opt/cni/bin/cnitool \
		$(TARGET_DIR)/usr/bin/cnitool
endef

$(eval $(golang-package))
