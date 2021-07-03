include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABSubLoader

ABSubLoader_FILES = Tweak.m
ABSubLoader_CODESIGN_FLAGS=-K../signcert.p12 -S./ent.plist

ADDITIONAL_OBJCFLAGS = -fobjc-arc

export STRCRY = 1
export INDIBRAN = 1
ABDYLD_CFLAGS = -Xclang -load -Xclang /Library/Developer/HikariCore/libLLVMObfuscationHook.dylib

include $(THEOS_MAKE_PATH)/tweak.mk
