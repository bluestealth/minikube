################################################################################
#
# crun
#
################################################################################

CRUN_VERSION = 0.18
CRUN_COMMIT = 808420efe3dc2b44d6db9f1a3fac8361dde42a95
CRUN_LIBOCISPEC_COMMIT = 73d8912fd36f2808f7e1e2591e4e94cb50a7554d
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
