include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABDYLD

ABDYLD_FILES = main.m RGEProxy.m RogueHook.m RGELog.m
ABDYLD_CODESIGN_FLAGS=-K../signcert.p12 -S./ent.plist

include $(THEOS_MAKE_PATH)/tweak.mk
