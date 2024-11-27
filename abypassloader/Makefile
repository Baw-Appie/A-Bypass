# TARGET = iphone:12.2:12.2
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABypassLoader

ABypassLoader_FILES = Tweak.xm ABPattern.m DYLDSaver.xm fishhook.c ImagePatcher.xm
ABypassLoader_LIBRARIES = mryipc Dobby
ABypassLoader_CODESIGN_FLAGS=-S./ent.plist

# Remove Symbols
ABypassLoader_CFLAGS += -fvisibility=hidden


include $(THEOS_MAKE_PATH)/tweak.mk
