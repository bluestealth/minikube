################################################################################
#
# conmon
#
################################################################################

CONMON_VERSION = v2.0.18
CONMON_COMMIT = 7b3e303be8f1aea7e0d4a784c8e64a75c14756a4
CONMON_SITE = https://github.com/containers/conmon/archive
CONMON_SOURCE = $(CONMON_VERSION).tar.gz
CONMON_LICENSE = Apache-2.0
CONMON_LICENSE_FILES = LICENSE

CONMON_DEPENDENCIES = host-pkgconf

define CONMON_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D) GIT_COMMIT=$(CONMON_COMMIT) PREFIX=/usr
endef

define CONMON_INSTALL_TARGET_CMDS
	$(INSTALL) -Dm755 $(@D)/bin/conmon $(TARGET_DIR)/usr/libexec/crio/conmon
	$(INSTALL) -Dm755 $(@D)/bin/conmon $(TARGET_DIR)/usr/libexec/podman/conmon
endef

$(eval $(generic-package))
