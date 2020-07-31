################################################################################
#
# crun
#
################################################################################

CRUN_VERSION = 0.14.1
CRUN_COMMIT = 88886aef25302adfd40a9335372bbc2b970c8ae5
CRUN_LIBOCISPEC_COMMIT = 69a096a965ae47c5a83832b87e1d0a5178ca0b30
CRUN_SITE = https://github.com/containers/crun/archive
CRUN_SOURCE = $(CRUN_VERSION).tar.gz
CRUN_LICENSE = Apache-2.0
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
		rmdir $(@D)/libocispec
		git -C $(@D) init
		git -C $(@D) submodule add https://github.com/containers/libocispec.git $(@D)/libocispec
		git -C $(@D)/libocispec checkout $(CRUN_LIBOCISPEC_COMMIT)
        cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

CRUN_PRE_CONFIGURE_HOOKS += CRUN_RUN_AUTOGEN

$(eval $(autotools-package))
