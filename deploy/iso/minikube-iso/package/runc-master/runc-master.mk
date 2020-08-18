################################################################################
#
# runc
#
################################################################################

# As of 2020-08-18, v1.0.0-rc92
RUNC_MASTER_SITE = https://github.com/opencontainers/runc/archive
RUNC_MASTER_VERSION = v1.0.0-rc92
RUNC_MASTER_COMMIT = ff819c7e9184c13b7c2607fe6c30ae19403a7aff
RUNC_MASTER_SOURCE = $(RUNC_MASTER_VERSION).tar.gz
RUNC_MASTER_LICENSE = Apache-2.0
RUNC_MASTER_LICENSE_FILES = LICENSE
RUNC_MASTER_BUILD_OPTS = -buildmode=pie
RUNC_MASTER_LDFLAGS = -X main.gitCommit=$(RUNC_MASTER_COMMIT) -X main.version=$(RUNC_MASTER_VERSION)
RUNC_MASTER_TAGS =
RUNC_MASTER_DEPENDENCIES = host-go
RUNC_MASTER_INSTALL_BINS = runc
RUNC_MASTER_BIN_NAME = runc
RUNC_MASTER_GO_ENV = \
	CGO_ENABLED=1 \
	GO111MODULE=off

ifeq ($(BR2_PACKAGE_APPARMOR),y)
RUNC_MASTER_TAGS += apparmor
RUNC_MASTER_DEPENDENCIES += libapparmor
endif
ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
RUNC_MASTER_TAGS += selinux
RUNC_MASTER_DEPENDENCIES += libselinux
endif
ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
RUNC_MASTER_TAGS += seccomp
RUNC_MASTER_DEPENDENCIES += libseccomp host-pkgconf
endif

$(eval $(golang-package))
