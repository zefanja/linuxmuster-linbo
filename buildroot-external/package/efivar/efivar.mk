################################################################################
#
# efivar
#
################################################################################

EFIVAR_VERSION = 0.23
EFIVAR_SITE = $(call github,rhinstaller,efivar,$(EFIVAR_VERSION))
EFIVAR_LICENSE = LGPLv2.1
EFIVAR_LICENSE_FILES = COPYING
EFIVAR_DEPENDENCIES = popt
EFIVAR_INSTALL_STAGING = YES

# BINTARGETS is set to skip efivar-static which requires static popt.
# -fPIC is requested at least on MIPS, otherwise fails to build shared library.
# Explicitly linking with shared libgcc is required at least on MicroBlaze,
# otherwise it fails due to FDE encoding in static libgcc.
EFIVAR_MAKE_OPTS = \
	libdir=/usr/lib \
	BINTARGETS=efivar \
	LDFLAGS=-fPIC \
	SOFLAGS="-shared -shared-libgcc"

define EFIVAR_BUILD_CMDS
	# makeguids is an internal host tool and must be built separately with
	# $(HOST_CC), otherwise it gets cross-built.
	$(HOST_MAKE_ENV) $(HOST_CONFIGURE_OPTS) \
		CFLAGS="$(HOST_CFLAGS) -std=c99" \
		$(MAKE) -C $(@D)/src makeguids 

	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE1) -C $(@D) \
		$(EFIVAR_MAKE_OPTS) \
		all
endef

define EFIVAR_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE1) -C $(@D) \
		$(EFIVAR_MAKE_OPTS) \
		DESTDIR="$(STAGING_DIR)" \
		install
endef

define EFIVAR_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE1) -C $(@D) \
		$(EFIVAR_MAKE_OPTS) \
		DESTDIR="$(TARGET_DIR)" \
		install
endef

$(eval $(generic-package))