VERSION = 0.2a

all: ipa deb apk

app:
	flutter build ios --release

ipa: app
	mkdir -p build/ios/iphoneos/Payload
	mv build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload
	rm -f build/$(VERSION).ipa
	cd build/ios/iphoneos && zip -r ../../$(VERSION).ipa Payload
	rm -rf build/ios/iphoneos/Payload

deb: app
	./build_deb.bash $(VERSION)

apk:
	flutter build apk --release
	mv build/app/outputs/apk/release/app-release.apk build/$(VERSION).apk

.PHONY: ios ipa apk
