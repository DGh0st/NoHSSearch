export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:11.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NoHSSearch
NoHSSearch_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += nohssearch
include $(THEOS_MAKE_PATH)/aggregate.mk
