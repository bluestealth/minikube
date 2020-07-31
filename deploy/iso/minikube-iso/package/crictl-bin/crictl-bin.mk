################################################################################
#
# crictl-bin
#
################################################################################

CRICTL_BIN_VERSION = v1.19.0
CRICTL_BIN_SITE = https://github.com/kubernetes-sigs/cri-tools/releases/download/$(CRICTL_BIN_VERSION)

ifeq ($(KERNEL_ARCH),x86_64)
CRICTL_BIN_SOURCE = crictl-$(CRICTL_BIN_VERSION)-linux-amd64.tar.gz
endif
ifeq ($(KERNEL_ARCH),arm64)
CRICTL_BIN_SOURCE = crictl-$(CRICTL_BIN_VERSION)-linux-arm64.tar.gz
endif

CRICTL_BIN_STRIP_COMPONENTS = 0

define CRICTL_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/crictl \
		$(TARGET_DIR)/usr/bin/crictl
endef

$(eval $(generic-package))
