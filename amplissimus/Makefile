VERSION = 0.6.0b

FLAGS = --release --split-debug-info=debug_symbols

all: cleanexes app ipa deb apk cleanartifacts

app:
	mkdir -p debug_symbols
	flutter build ios $(FLAGS)
	xcrun bitcode_strip build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter -r -o tmpfltr
	mv -f tmpfltr build/ios/Release-iphoneos/Runner.app/Frameworks/Flutter.framework/Flutter

ipa:
	mkdir Payload
	cp -r build/ios/Release-iphoneos/Runner.app Payload
	zip -r -9 $(VERSION).ipa Payload

deb:
	./build_deb.bash $(VERSION)

apk:
	mkdir -p debug_symbols
	flutter build apk $(FLAGS)
	mv build/app/outputs/apk/release/app-release.apk $(VERSION).apk

cleanexes:
	cd bin && rm -f $(VERSION).ipa $(VERSION).deb $(VERSION).apk

cleanartifacts:
	mkdir -p bin
	mv -f $(VERSION).* bin
	flutter clean
	rm -rf Payload debug_symbols

.PHONY: cleanexes cleanartifacts ios ipa apk
