TARGET = iphone:clang:12.2:12.2
ARCHS = arm64 arm64e
PREFIX="/Library/Developer/TheosToolchains/Xcode11.xctoolchain/usr/bin/"
# STRIP = 0

CURDIR := $(shell pwd)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = !ABypass2
!ABypass2_FILES = Tweak.xm ABWindow.m
!ABypass2_LIBRARIES = mryipc MobileGestalt


export STRCRY = 1
export INDIBRAN = 1
!ABypass2_CFLAGS = -Xclang -load -Xclang /Library/Developer/HikariCore/libLLVMObfuscationHook.dylib


include $(THEOS_MAKE_PATH)/tweak.mk

# after-install::
# 	install.exec "killall -9 SpringBoard"

before-stage::
	find . -name ".DS\_Store" -delete

SUBPROJECTS += abypassprefs
SUBPROJECTS += abypassloader
SUBPROJECTS += ABdyld
SUBPROJECTS += absubloader
include $(THEOS_MAKE_PATH)/aggregate.mk


after-stage::
	@mkdir -p $(THEOS_STAGING_DIR)/usr/lib
	@mv $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/ABDYLD.dylib $(THEOS_STAGING_DIR)/usr/lib/ABDYLD.dylib
	@rm $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/ABDYLD.plist
	@mv $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/ABSubLoader.dylib $(THEOS_STAGING_DIR)/usr/lib/ABSubLoader.dylib
	@rm $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/ABSubLoader.plist
	@./afterProcess.sh $(DEBUG)
