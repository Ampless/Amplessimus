VERSION = 0.4.1b

all: cleanexes ipa deb apk

app:
	flutter build ios --release

ipa: app
	mkdir -p build/Payload
	cp -r build/ios/iphoneos/Runner.app build/Payload
	cd build && zip -r -9 $(VERSION).ipa Payload
	rm -rf build/Payload

deb: app
	./build_deb.bash $(VERSION)

apk:
	flutter build apk --release
	mv build/app/outputs/apk/release/app-release.apk build/$(VERSION).apk

cleanexes:
	cd build && rm -f $(VERSION).ipa $(VERSION).deb $(VERSION).apk

.PHONY: cleanexes ios ipa apk
