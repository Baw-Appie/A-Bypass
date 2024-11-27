#/bin/sh

echo !!!! ----------------------------------------------------------- !!!!
echo !!!! YOU MUST RESPRING YOUR DEVICE !!!!
echo !!!! ----------------------------------------------------------- !!!!
mkdir ./.theos/_/Library/BawAppie/
mkdir ./.theos/_/Library/BawAppie/ABypass
mv ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.dylib ./.theos/_/Library/BawAppie/ABypass/ABLicense
rm ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ABypassLoader.plist