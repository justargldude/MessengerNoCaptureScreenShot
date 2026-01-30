TARGET := iphone:clang:latest:14.0
TWEAK_NAME = ScreenCaptureBypass
ScreenCaptureBypass_FILES = Tweak.xm
ScreenCaptureBypass_CFLAGS = -fobjc-arc
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
