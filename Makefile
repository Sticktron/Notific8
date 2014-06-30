ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0
THEOS_BUILD_DIR = Packages

TWEAK_NAME = Notific8
Notific8_CFLAGS = -fobjc-arc
Notific8_FILES = Tweak.xm NewAttributionWidget.mm
Notific8_FRAMEWORKS = Foundation UIKit CoreGraphics
Notific8_PRIVATE_FRAMEWORKS = SpringBoardUIServices

SUBPROJECTS += Settings

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
	#install.exec "killall -HUP SpringBoard"
