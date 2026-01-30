TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Messenger

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ScreenCaptureBypass

ScreenCaptureBypass_FILES = Tweak.xm
ScreenCaptureBypass_CFLAGS = -fobjc-arc
ScreenCaptureBypass_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
