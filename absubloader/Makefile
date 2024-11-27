include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABSubLoader

ABSubLoader_FILES = Tweak.m
ABSubLoader_CODESIGN_FLAGS=-K../signcert.p12 -S./ent.plist

ADDITIONAL_OBJCFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
