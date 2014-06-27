ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = Notific8
Notific8_CFLAGS = -fobjc-arc
Notific8_FILES = Tweak.xm NewAttributionWidget.m
Notific8_FRAMEWORKS = Foundation UIKit CoreGraphics
Notific8_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Settings
include $(THEOS_MAKE_PATH)/aggregate.mk


after-install::
	#install.exec "killall -HUP SpringBoard"
	install.exec "killall -9 backboardd"
