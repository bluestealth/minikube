################################################################################
#
# crun
#
################################################################################

CRUN_VERSION = 0.15
CRUN_COMMIT = 56ca95e61639510c7dbd39ff512f80f626404969
CRUN_LIBOCISPEC_COMMIT = 5dfe2f406dc2d0f244aec621292e4e0a52149240
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
