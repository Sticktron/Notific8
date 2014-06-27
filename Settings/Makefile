ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = Notific8Settings
Notific8Settings_CFLAGS = -fobjc-arc
Notific8Settings_FILES = Notific8Settings.m
Notific8Settings_INSTALL_PATH = /Library/PreferenceBundles
Notific8Settings_FRAMEWORKS = Foundation UIKit
Notific8Settings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Notific8Settings.plist$(ECHO_END)
