VERSION = 1.1.0

FLAGS = --release --split-debug-info=debug_symbols --obfuscate
IOS_FLAGS = $(FLAGS)
APK_FLAGS = $(FLAGS) --shrink

all: mkdirs ios android

android: apk cleanartifacts

ios: app ipa deb cleanartifacts

app:
	mkdir -p debug_symbols
	flutter build ios $(IOS_FLAGS)
	xcrun bitcode_strip build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter

ipa:
	mkdir Payload
	cp -r build/ios/Release-iphoneos/Runner.app Payload
	zip -r -9 bin/$(VERSION).ipa Payload

deb:
	./build_deb.bash $(VERSION)

apk:
	mkdir -p debug_symbols
	flutter build apk $(APK_FLAGS)
	mv build/app/outputs/apk/release/app-release.apk bin/$(VERSION).apk

mkdirs:
	mkdir -p bin

cleanartifacts:
	flutter clean
	rm -rf Payload debug_symbols

.PHONY: cleanartifacts ios ipa apk
