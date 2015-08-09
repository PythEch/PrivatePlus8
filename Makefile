THEOS_PACKAGE_DIR_NAME = debs
TARGET = iphone:clang
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = Inpornito
Inpornito_FILES = Tweak.xm
Inpornito_FRAMEWORKS = UIKit QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
