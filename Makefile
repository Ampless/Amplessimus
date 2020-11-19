VERSION = 2.5.1
ACTUAL_VERSION = $(VERSION).$$(git rev-parse @ | cut -c 1-7)

FLAGS = --release --suppress-analytics
BIN_FLAGS = $(FLAGS) --split-debug-info=/tmp --obfuscate
IOS_FLAGS = $(BIN_FLAGS)
APK_FLAGS = $(BIN_FLAGS) --shrink --target-platform android-arm,android-arm64,android-x64
AAB_FLAGS = $(APK_FLAGS)
WIN_FLAGS = $(BIN_FLAGS)
GTK_FLAGS = $(BIN_FLAGS)
MAC_FLAGS = $(BIN_FLAGS)
WEB_FLAGS = $(FLAGS) --csp

TEST_FLAGS = --coverage -j 100 --test-randomize-ordering-seed random

IOS_BUILD_DIR = build/ios/Release-iphoneos/Runner.app
IOS_STRIP_LIST = $(IOS_BUILD_DIR)/Runner \
				 $(IOS_BUILD_DIR)/Frameworks/App.framework/App \
				 $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter \
				 $(IOS_BUILD_DIR)/Frameworks/shared_preferences.framework/shared_preferences
MAC_BUILD_DIR = build/macos/Build/Products/Release/Amplessimus.app
MAC_STRIP_LIST = $(MAC_BUILD_DIR)/Contents/Runner \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/App.framework/Versions/A/App \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/FlutterMacOS.framework/Versions/A/FlutterMacOS \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/shared_preferences_macos.framework/Versions/A/shared_preferences_macos \
				 $(MAC_BUILD_DIR)/Contents/Frameworks/*.dylib
STRIP = strip -u -r
BITCODE_STRIP = xcrun bitcode_strip

OUTPUT_DIR = bin
OUTPUT_APK = $(OUTPUT_DIR)/$(ACTUAL_VERSION).apk
OUTPUT_AAB = $(OUTPUT_DIR)/$(ACTUAL_VERSION).aab
OUTPUT_DEB = $(OUTPUT_DIR)/$(ACTUAL_VERSION).deb
OUTPUT_DMG = $(OUTPUT_DIR)/$(ACTUAL_VERSION).dmg
OUTPUT_IPA = $(OUTPUT_DIR)/$(ACTUAL_VERSION).ipa
OUTPUT_GTK = $(OUTPUT_DIR)/$(ACTUAL_VERSION).linux
OUTPUT_WEB = $(OUTPUT_DIR)/$(ACTUAL_VERSION).web
OUTPUT_WIN = $(OUTPUT_DIR)/$(ACTUAL_VERSION).win

TMP         = tmp
    IPA_DIR = Payload
TMP_IPA_DIR = $(TMP)/$(IPA_DIR)
TMP_DEB_DIR = $(TMP)/deb
TMP_DMG_DIR = $(TMP)/dmg
TMP_DMG     = $(TMP)/tmp.dmg


ci: mkdirs replaceversions iosapp ipa apk cleanartifacts rollbackversions

android: mkdirs replaceversions apk aab cleanartifacts rollbackversions
ios: mkdirs replaceversions iosapp ipa deb cleanartifacts rollbackversions
web: mkdirs replaceversions webbuild cleanartifacts rollbackversions
win: mkdirs replaceversions winx64 cleanartifacts rollbackversions
mac: mkdirs replaceversions macapp macdmg cleanartifacts rollbackversions
linux: mkdirs replaceversions linux64 cleanartifacts rollbackversions

replaceversions:
	@which mv sed
	mv -f pubspec.yaml pubspec.yaml.def
	sed "s/0.0.0-1/$(VERSION)/" pubspec.yaml.def > pubspec.yaml
	mv -f lib/values.dart lib/values.dart.def
	sed "s/0.0.0-1/$(ACTUAL_VERSION)/" lib/values.dart.def > lib/values.dart

# TODO: call this always
rollbackversions:
	@which mv
	mv -f pubspec.yaml.def pubspec.yaml
	mv -f lib/values.dart.def lib/values.dart

iosapp:
	@which flutter xcrun mv strip
	flutter build ios $(IOS_FLAGS)
	$(BITCODE_STRIP) $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr $(IOS_BUILD_DIR)/Frameworks/Flutter.framework/Flutter
	rm -f $(IOS_BUILD_DIR)/Frameworks/libswift*
	$(STRIP) $(IOS_STRIP_LIST) || true

ipa:
	@which cp rm cd zip
	cp -rp $(IOS_BUILD_DIR) $(TMP_IPA_DIR)
	rm -rf $(OUTPUT_IPA)
	cd $(TMP) && zip -r -9 ../$(OUTPUT_IPA) $(IPA_DIR)

# http://www.saurik.com/id/7
# but its broken...
deb:
	@which cp sh du grep sed md5sum awk ls dpkg-deb
	cp -rp $(IOS_BUILD_DIR) $(TMP_DEB_DIR)/Applications/
	VERSION=$(VERSION) BUILD_DIR=$(IOS_BUILD_DIR) INPUT=control.def OUTPUT=$(TMP_DEB_DIR)/DEBIAN/control sh sedit.sh
	COPYFILE_DISABLE= COPY_EXTENDED_ATTRIBUTES_DISABLE= dpkg-deb -Sextreme -z9 --build $(TMP_DEB_DIR) $(OUTPUT_DEB)

cydiainfo:
	@which sh gzip du grep sed md5sum awk ls
	VERSION=$(VERSION) BUILD_DIR=$(IOS_BUILD_DIR) DEB=$(OUTPUT_DEB) INPUT=Packages.def OUTPUT=$(OUTPUT_DIR)/Packages sh sedit.sh
	gzip -9 -c $(OUTPUT_DIR)/Packages > $(OUTPUT_DIR)/Packages.gz

apk:
	@which flutter mv
	flutter build apk $(APK_FLAGS)
	mv build/app/outputs/apk/release/app-release.apk $(OUTPUT_APK)

aab:
	@which flutter mv
	flutter build appbundle $(AAB_FLAGS)
	mv build/app/outputs/bundle/release/app-release.aab $(OUTPUT_AAB)

webbuild:
	@which flutter mv
	flutter channel master
	flutter upgrade
	flutter config --enable-web
	flutter build web $(WEB_FLAGS)
	mv build/web $(OUTPUT_WEB)

winx64:
	@which flutter mv
	flutter channel master
	flutter upgrade
	flutter config --enable-windows-desktop
	flutter build windows $(WIN_FLAGS)
	mv build/windows/x64/Release/Runner $(OUTPUT_WIN)

linux64:
	@which flutter mv
	flutter channel master
	flutter upgrade
	flutter config --enable-linux-desktop
	flutter build linux $(GTK_FLAGS)
	mv build/linux/release/bundle $(OUTPUT_GTK)

macapp:
	@which flutter strip
	flutter channel master
	flutter upgrade
	flutter config --enable-macos-desktop
	flutter build macos $(MAC_FLAGS)
	$(STRIP) $(MAC_STRIP_LIST) || true

macdmg:
	@which cp ln hdiutil
	cp -rf $(MAC_BUILD_DIR) $(TMP_DMG_DIR)
	ln -s /Applications $(MAC_BUILD_DIR)/Applications
	hdiutil create $(TMP_DMG) -ov -srcfolder $(TMP_DMG_DIR) -fs APFS -volname "Install Amplessimus"
	hdiutil convert $(TMP_DMG) -ov -format UDBZ -o $(OUTPUT_DMG)

mkdirs:
	@which mkdir
	mkdir -p $(OUTPUT_DIR) $(TMP_IPA_DIR) $(TMP_DEB_DIR)/DEBIAN $(TMP_DEB_DIR)/Applications $(TMP_DMG_DIR)

cleanartifacts:
	@which rm
	rm -rf $(TMP)/*

test:
	flutter test $(TEST_FLAGS) || make test
	genhtml -o coverage/html coverage/lcov.info
	lcov -l coverage/lcov.info

.PHONY: replaceversions rollbackversions iosapp ipa deb apk aab webbuild winx64 linux64 macapp macdmg mkdirs cleanartifacts test
