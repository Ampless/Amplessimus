VERSION = 1.1.2

FLAGS = --release --suppress-analytics
BIN_FLAGS = $(FLAGS) --split-debug-info=debug_symbols --obfuscate
IOS_FLAGS = $(BIN_FLAGS)
APK_FLAGS = $(BIN_FLAGS) --shrink --target-platform android-arm,android-arm64,android-x64
WIN_FLAGS = $(BIN_FLAGS)
GTK_FLAGS = $(BIN_FLAGS)
MAC_FLAGS = $(BIN_FLAGS)
WEB_FLAGS = $(FLAGS) --csp

IOS_BUILD_DIR = build/ios/Release-iphoneos/Runner.app

all: mkdirs replaceversions iosapp ipa deb apk webbuild cleanartifacts rollbackversions

android: mkdirs replaceversions apk cleanartifacts rollbackversions
ios: mkdirs replaceversions iosapp ipa deb cleanartifacts rollbackversions
web: mkdirs replaceversions webbuild cleanartifacts rollbackversions
win: mkdirs replaceversions winx64 cleanartifacts rollbackversions
mac: mkdirs replaceversions macapp macdmg cleanartifacts rollbackversions
linux: mkdirs replaceversions linux64 cleanartifacts rollbackversions

replaceversions:
	mv -f pubspec.yaml pubspec.yaml.def
	sed "s/0.0.0-1/$(VERSION)/" pubspec.yaml.def > pubspec.yaml
	mv -f lib/values.dart lib/values.dart.def
	sed "s/0.0.0-1/$(VERSION)/" lib/values.dart.def > lib/values.dart

rollbackversions:
	mv -f pubspec.yaml.def pubspec.yaml
	mv -f lib/values.dart.def lib/values.dart

iosapp:
	flutter build ios $(IOS_FLAGS)
	xcrun bitcode_strip $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter
	strip -u -r $(IOS_BUILD_DIR)/Frameworks/App.framework/App $(IOS_BUILD_DIR)/Frameworks/libswift*

ipa:
	cp -rp build/ios/Release-iphoneos/Runner.app Payload
	rm -rf bin/$(VERSION).ipa
	zip -r -9 bin/$(VERSION).ipa Payload

# This is for Cydia: http://www.saurik.com/id/7
deb:
	cp -rp build/ios/Release-iphoneos/Runner.app tmp2deb/Applications/
	grep -v "^#" control.def | \
	  sed "s/\$$VERSION/$(VERSION)/" | \
	  sed "s/\$$SIZE/`du -sk build/ios/Release-iphoneos/Runner.app | awk '{ print $$1 }'`/" | \
	  sed "s/\$$ARCH/iphoneos-arm/" > tmp2deb/DEBIAN/control
	COPYFILE_DISABLE= COPY_EXTENDED_ATTRIBUTES_DISABLE= dpkg-deb -Sextreme -z9 --build tmp2deb bin/$(VERSION).deb

apk:
	flutter build apk $(APK_FLAGS)
	mv build/app/outputs/apk/release/app-release.apk bin/$(VERSION).apk

webbuild:
	flutter build web $(WEB_FLAGS)
	mv build/web bin/$(VERSION).web

winx64:
	flutter build windows $(WIN_FLAGS)
	mv build/windows/x64/Release/Runner bin/$(VERSION).win

linux64:
	flutter build linux $(GTK_FLAGS)
	mv build/linux/release/bundle bin/$(VERSION).linux

macapp:
	flutter build macos $(MAC_FLAGS)

macdmg:
	cp -rf build/macos/Build/Products/Release/Amplissimus.app tmp2dmg
	ln -s /Applications tmp2dmg/Applications
	hdiutil create tmp.dmg -ov -srcfolder tmp2dmg -fs APFS -volname AmplissimusInstall
	hdiutil convert tmp.dmg -ov -format UDBZ -o bin/$(VERSION).dmg

mkdirs:
	mkdir -p debug_symbols bin Payload tmp2deb/DEBIAN tmp2deb/Applications tmp2dmg

cleanartifacts:
	flutter clean
	rm -rf Payload tmp2deb tmp2dmg tmp.dmg

setup:
	sudo apt install -y cmake ninja-build

.PHONY: replaceversions rollbackversions iosapp ipa deb apk webbuild winx64 linux64 macapp macdmg mkdirs cleanartifacts
