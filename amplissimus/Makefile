VERSION = a0.2

ios:
	flutter build ios --release
	mkdir -p build/ios/iphoneos/Payload
	mv build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload
	cd build/ios/iphoneos && zip -r $(VERSION).ipa Payload
	rm -rf build/ios/iphoneos/Payload

apk:
	flutter build apk --release
	cd build/app/outputs/apk/release && mv app-release.apk $(VERSION).apk

.PHONY: ios
