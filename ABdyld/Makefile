include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABDYLD

ABDYLD_FILES = main.m RGEProxy.m RogueHook.m RGELog.m
ABDYLD_CODESIGN_FLAGS=-K../signcert.p12 -S./ent.plist

export STRCRY = 1
export INDIBRAN = 1
ABDYLD_CFLAGS = -Xclang -load -Xclang /Library/Developer/HikariCore/libLLVMObfuscationHook.dylib

include $(THEOS_MAKE_PATH)/tweak.mk
