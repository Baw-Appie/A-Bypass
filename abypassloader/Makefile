# TARGET = iphone:12.2:12.2
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ABypassLoader

ABypassLoader_FILES = ReverseMessage.m Tweak.xm ABPattern.m DYLDSaver.xm fishhook.c ImagePatcher.xm
ABypassLoader_LIBRARIES = mryipc Dobby
ABypassLoader_CODESIGN_FLAGS=-S./ent.plist


#  ----- [ Hikari ] -----

TARGET_CC = /Library/Developer/Toolchains/Hikari.xctoolchain/usr/bin/clang
TARGET_CXX = /Library/Developer/Toolchains/Hikari.xctoolchain/usr/bin/clang++

unexport STRCRY
# unexport INDIBRAN
ABypassLoader_CFLAGS += -mllvm -enable-indibran -mllvm -enable-funcwra
# ABypassLoader_CFLAGS += -mllvm -enable-strcry


include $(THEOS_MAKE_PATH)/tweak.mk
