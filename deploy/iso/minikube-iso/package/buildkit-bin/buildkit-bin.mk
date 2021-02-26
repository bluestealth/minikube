################################################################################
#
# buildkit-bin
#
################################################################################

BUILDKIT_BIN_VERSION = v0.8.2
BUILDKIT_BIN_COMMIT = 9065b18ba4633c75862befca8188de4338d9f94a
BUILDKIT_BIN_SITE = https://github.com/moby/buildkit/releases/download/$(BUILDKIT_BIN_VERSION)
ifeq ($(KERNEL_ARCH),x86_64)
BUILDKIT_BIN_SOURCE = buildkit-$(BUILDKIT_BIN_VERSION).linux-amd64.tar.gz
endif
ifeq ($(KERNEL_ARCH),arm64)
BUILDKIT_BIN_SOURCE = buildkit-$(BUILDKIT_BIN_VERSION).linux-arm64.tar.gz
endif



# https://github.com/opencontainers/runc.git
BUILDKIT_RUNC_VERSION = v1.0.0-rc93

define BUILDKIT_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/buildctl \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 \
		$(@D)/buildkit-runc \
		$(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 \
		$(@D)/buildkitd \
		$(TARGET_DIR)/usr/sbin
endef

$(eval $(generic-package))
