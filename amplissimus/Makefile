VERSION = a0.2

all: ipa apk

ipa:
	flutter build ios --release
	mkdir -p build/ios/iphoneos/Payload
	mv build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload
	zip -r build/$(VERSION).ipa build/ios/iphoneos/Payload
	rm -rf build/ios/iphoneos/Payload

apk:
	flutter build apk --release
	mv build/app/outputs/apk/release/app-release.apk build/$(VERSION).apk

.PHONY: ios apk
