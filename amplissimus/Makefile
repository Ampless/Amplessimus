VERSION = 1.1.0

FLAGS = --release --split-debug-info=debug_symbols --obfuscate
IOS_FLAGS = $(FLAGS)
APK_FLAGS = $(FLAGS) --shrink

all: ios android

android: mkdirs replaceversions apk cleanartifacts rollbackversions

ios: mkdirs replaceversions app ipa deb cleanartifacts rollbackversions

replaceversions:
	mv pubspec.yaml pubspec.yaml.def
	sed "s/0.0.0-1/$(VERSION)/" pubspec.yaml.def > pubspec.yaml
	mv lib/values.dart lib/values.dart.def
	sed "s/0.0.0-1/$(VERSION)/" lib/values.dart.def > lib/values.dart

rollbackversions:
	mv pubspec.yaml.def pubspec.yaml
	mv lib/values.dart.def lib/values.dart

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

mkdirs:
	mkdir -p debug_symbols bin Payload tmp2deb/DEBIAN tmp2deb/Applications

cleanartifacts:
	flutter clean
	rm -rf Payload debug_symbols tmp2deb

.PHONY: cleanartifacts ios ipa apk
