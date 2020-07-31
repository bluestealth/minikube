################################################################################
#
# crun
#
################################################################################

CRUN_VERSION = 0.17
CRUN_COMMIT = 0e9229ae34caaebcb86f1fde18de3acaf18c6d9a
CRUN_LIBOCISPEC_COMMIT = df96ab4041005d8bc491c1c1f63fedbf28caf9ee
CRUN_SITE = https://github.com/containers/crun/releases/download/$(CRUN_VERSION)
CRUN_SOURCE = crun-$(CRUN_VERSION).tar.xz
CRUN_LICENSE = GPLv2+
CRUN_LICENSE_FILES = LICENSE

CRUN_DEPENDENCIES = host-pkgconf libtool host-python3 host-go
CRUN_DEPENDENCIES += libcap systemd yajl
ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
CRUN_DEPENDENCIES += libselinux
endif
ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
CRUN_DEPENDENCIES += libseccomp
endif


define CRUN_RUN_AUTOGEN
        cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

CRUN_PRE_CONFIGURE_HOOKS += CRUN_RUN_AUTOGEN

$(eval $(autotools-package))
