################################################################################
#
# gluster
#
################################################################################

GLUSTER_VERSION = 8.3
GLUSTER_SITE = https://download.gluster.org/pub/gluster/glusterfs/$(shell echo $(GLUSTER_VERSION) | cut -d. -f1)/$(GLUSTER_VERSION)
GLUSTER_SOURCE = glusterfs-$(GLUSTER_VERSION).tar.gz
GLUSTER_CONF_OPTS = --disable-ec-dynamic --disable-georeplication --disable-gnfs --disable-cmocka --without-server
GLUSTER_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) install
$(eval $(autotools-package))
