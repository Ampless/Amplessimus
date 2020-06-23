VERSION = 1.1.4

FLAGS = --release --suppress-analytics
BIN_FLAGS = $(FLAGS) --split-debug-info=debug_symbols --obfuscate
IOS_FLAGS = $(BIN_FLAGS)
APK_FLAGS = $(BIN_FLAGS) --shrink --target-platform android-arm,android-arm64,android-x64
WIN_FLAGS = $(BIN_FLAGS)
GTK_FLAGS = $(BIN_FLAGS)
MAC_FLAGS = $(BIN_FLAGS)
WEB_FLAGS = $(FLAGS) --csp

IOS_BUILD_DIR = build/ios/Release-iphoneos/Runner.app
IOS_STRIP_LIST = $(IOS_BUILD_DIR)/Runner \
				 $(IOS_BUILD_DIR)/Frameworks/App.framework/App \
				 $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter \
				 $(IOS_BUILD_DIR)/Frameworks/shared_preferences.framework/shared_preferences \
				 $(IOS_BUILD_DIR)/Frameworks/*.dylib
MAC_BUILD_DIR = build/macos/Build/Products/Release/Amplissimus.app
MAC_STRIP_LIST = $(MAC_BUILD_DIR)/Contents/Runner \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/App.framework/Versions/A/App \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/FlutterMacOS.framework/Versions/A/FlutterMacOS \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/shared_preferences_macos.framework/Versions/A/shared_preferences_macos \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/*.dylib
STRIP = strip -u -r
BITCODE_STRIP = xcrun bitcode_strip

TMP_IPA_DIR = Payload
TMP_DEB_DIR = tmp2deb
TMP_DMG_DIR = tmp2dmg
TMP_DMG     = tmp.dmg

ci: mkdirs replaceversions iosapp ipa deb apk macapp macdmg cleanartifacts rollbackversions

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
	$(BITCODE_STRIP) $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter
	$(STRIP) $(IOS_STRIP_LIST)

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
	$(STRIP) $(MAC_STRIP_LIST)

macdmg:
	cp -rf $(MAC_BUILD_DIR) $(TMP_DMG_DIR)
	ln -s /Applications $(MAC_BUILD_DIR)/Applications
	hdiutil create $(TMP_DMG) -ov -srcfolder $(TMP_DMG_DIR) -fs APFS -volname AmplissimusInstall
	hdiutil convert $(TMP_DMG) -ov -format UDBZ -o bin/$(VERSION).dmg

mkdirs:
	mkdir -p debug_symbols bin $(TMP_IPA_DIR) $(TMP_DEB_DIR)/DEBIAN $(TMP_DEB_DIR)/Applications $(TMP_DMG_DIR)

cleanartifacts:
	flutter clean
	rm -rf $(TMP_IPA_DIR) $(TMP_DEB_DIR) $(TMP_DMG_DIR) $(TMP_DMG)

setup:
	sudo apt install -y cmake ninja-build

.PHONY: replaceversions rollbackversions iosapp ipa deb apk webbuild winx64 linux64 macapp macdmg mkdirs cleanartifacts
