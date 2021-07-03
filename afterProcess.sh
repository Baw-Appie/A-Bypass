#/bin/sh

if [ $1 -eq 1 ]; then

	echo !!!! ----------------------------------------------------------- !!!!
	echo !!!! DEBUG MODE ENABLED !!!!
	echo !!!! YOU MUST RESPRING YOUR DEVICE !!!!
	echo !!!! ----------------------------------------------------------- !!!!
	mkdir ./.theos/_/Library/BawAppie/
	mkdir ./.theos/_/Library/BawAppie/ABypass
	mv ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.dylib ./.theos/_/Library/BawAppie/ABypass/ABLicense
	rm ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.plist

else

	echo !!!! ----------------------------------------------------------- !!!!
	echo !!!! BUILD WITH PRODUCTION MODE !!!!
	echo !!!! YOU MUST UPLOAD ABLOADER TO SERVER !!!!
	echo !!!! ----------------------------------------------------------- !!!!
	echo !!!! PLEASE CHECK VERSION OF PREFERENCE !!!!
	echo !!!! ----------------------------------------------------------- !!!!
	mkdir ./.theos/_/Library/BawAppie/
	mkdir ./.theos/_/Library/BawAppie/ABypass
	mv ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.dylib ./찾을테면찾아보시지!5
	rm ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.plist

fi