TARGET = iphone:12.2:12.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ABypassPrefs
ABypassPrefs_FILES = ABPRootListController.m ABPAppDetailController.m ABPAppListController.m
ABypassPrefs_INSTALL_PATH = /Library/PreferenceBundles
ABypassPrefs_FRAMEWORKS = UIKit
ABypassPrefs_PRIVATE_FRAMEWORKS = Preferences
ABypassPrefs_LIBRARIES = applist mryipc
ABypassPrefs_CFLAGS = -DVERSION="@\"$(THEOS_PACKAGE_BASE_VERSION)\""

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ABypassPrefs.plist$(ECHO_END)
