################################################################################
#
# esp8089
#
################################################################################

ESP8089_VERSION = cleanup
ESP8089_SITE = $(call github,Icenowy,esp8089,$(ESP8089_VERSION))
ESP8089_LICENSE = GPL-2.0
ESP8089_LICENSE_FILES = LICENSE

ESP8089_MODULE_MAKE_OPTS = \
	CONFIG_ESP8089=m \
	KVER=$(LINUX_VERSION_PROBED) \
	KSRC=$(LINUX_DIR) \
	KBUILD=$(LINUX_DIR) \
	EXTRA_CFLAGS="-DCONFIG_ESP8089_DEBUG=0" \
	ARCH=$(KERNEL_ARCH) \
	CROSS_COMPILE=$(TARGET_CROSS)

ESP8089_DEPENDENCIES = linux

define ESP8089_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_NET)
	$(call KCONFIG_ENABLE_OPT,CONFIG_WIRELESS)
	$(call KCONFIG_ENABLE_OPT,CONFIG_CFG80211)
	$(call KCONFIG_ENABLE_OPT,CONFIG_MAC80211)
endef

define ESP8089_BUILD_CMDS
	$(MAKE) -C $(LINUX_DIR) M=$(@D) modules $(ESP8089_MODULE_MAKE_OPTS)
endef

define ESP8089_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/esp8089.ko $(TARGET_DIR)/lib/modules/$(LINUX_VERSION_PROBED)/extra/esp8089.ko
endef

$(eval $(kernel-module))
$(eval $(generic-package))