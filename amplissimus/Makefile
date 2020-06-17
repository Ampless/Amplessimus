VERSION = 1.1.1

FLAGS = --release --suppress-analytics
BIN_FLAGS = $(FLAGS) --split-debug-info=debug_symbols --obfuscate
IOS_FLAGS = $(BIN_FLAGS)
APK_FLAGS = $(BIN_FLAGS) --shrink --target-platform android-arm,android-arm64,android-x64
WIN_FLAGS = $(BIN_FLAGS)
WEB_FLAGS = $(FLAGS) --csp

all: ios android web

android: mkdirs replaceversions apk cleanartifacts rollbackversions
ios: mkdirs replaceversions app ipa deb cleanartifacts rollbackversions
web: mkdirs replaceversions _web cleanartifacts rollbackversions
win: mkdirs replaceversions winx64 cleanartifacts rollbackversions

replaceversions:
	mv -f pubspec.yaml pubspec.yaml.def
	sed "s/0.0.0-1/$(VERSION)/" pubspec.yaml.def > pubspec.yaml
	mv -f lib/values.dart lib/values.dart.def
	sed "s/0.0.0-1/$(VERSION)/" lib/values.dart.def > lib/values.dart

rollbackversions:
	mv -f pubspec.yaml.def pubspec.yaml
	mv -f lib/values.dart.def lib/values.dart

app:
	flutter build ios $(IOS_FLAGS)
	xcrun bitcode_strip build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter

ipa:
	cp -rp build/ios/Release-iphoneos/Runner.app Payload
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

_web:
	flutter build web $(WEB_FLAGS)
	mv build/web bin/$(VERSION).web

winx64:
	flutter build windows $(WIN_FLAGS)
	mv build/windows/x64/Release/Runner bin/$(VERSION).win

mkdirs:
	mkdir -p debug_symbols bin Payload tmp2deb/DEBIAN tmp2deb/Applications

cleanartifacts:
	flutter clean
	rm -rf Payload debug_symbols tmp2deb

.PHONY: cleanartifacts replaceversions rollbackversions ios ipa apk
