TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Messenger
include $(THEOS)/makefiles/common.mk
TWEAK_NAME = ScreenCaptureBypass
ScreenCaptureBypass_FILES = Tweak.xm
ScreenCaptureBypass_CFLAGS = -fobjc-arc
include $(THEOS_MAKE_PATH)/tweak.mk

static BOOL isEnabled() {
    return YES; // Luôn bật vì không đọc được file plist hệ thống
}

static BOOL shouldBlockNotification() {
    return YES; // Luôn chặn
}