VERSION = 2.6.1337
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
				 $(IOS_BUILD_DIR)/Frameworks/*.framework/*
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


ci:
	dart run make.dart ci

android:
	dart run make.dart android

ios:
	dart run make.dart ios

web:
	dart run make.dart web

win:
	dart run make.dart win

mac:
	dart run make.dart mac

linux:
	dart run make.dart linux

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

test:
	dart run make.dart test

.PHONY: deb aab webbuild winx64 linux64 macapp macdmg test
