# Amplessimus
Amplessimus is an app that tries to be what the 'DSBMobile' app could
have been. It currently supports Android, iOS, Linux, macOS and
Windows.

## Why not the browser?
We could theoretically build a webapp version of this with
almost no effort, BUT it would require a proxy server of some kind as
all mainstream browsers try to block, what is called CSRF: You open up
evil.com and in JavaScript it makes a request to bank.com that tells
it to send me $1000. Of course we, as well as the browser vendors
should, know that making requests to DSBMobile probably cannot ever
be abused in a relevant way, but that doesn't fix the problem. Proxy
servers are a solution for this and, while we might one day make one,
that makes it quite a bit harder to run this as a webapp.

## Installing
Just take the binary and install it in your OS's standard way.
### Android
Download the APK and click `Install`.
### Linux, Windows
Flutter doesn't cross-compile at the moment. Goto [`Building`](#build).
### macOS
Download and mount the DMG and drag-and-drop Amplessimus into the Applications.
### iOS
iOS installation is interesting, because, to run on iOS "officially",
we would have to pay Apple $99/year.
#### Filza (jailbroken)
The easiest way to install any IPA is to just open Filza, go to the
Downloads folder, click the file and then on `Install`.
#### Current AltStore Beta
In Beta 5 of AltStore 1.4 a new feature was added: You can add the Amplessimus
source by clicking
[this link](altstore://source?url=https://ampless.chrissx.de/altstore/stable.json).
#### AltStore 1.4 Beta 1-4
Some AltStore Betas allowed you to add custom software
repositories. Go to `Browse` → `Sources` → `+` and enter:
```
https://ampless.chrissx.de/altstore/stable.json
```
and you can install Amplessimus like you would install Riley's apps.
#### AltStore 1.3 and older
AltStore allows you to install IPAs. Download the IPA and install it,
either with the `+` button in AltStore or by using `open in` AltStore.

## <a name="build"></a> Building
Compiling for everything except Windows will assume you are running
macOS or Linux, but nowadays Windows should work, too. However, for
all build targets a recent version of
[Flutter](https://flutter.dev/docs/get-started/install) is required.
In the Output sections `$VERSION` means "the full name of the version
you are building". (e.g. 3.6.22) All of the outputs are placed in the
`bin/` folder, which is created automatically.

### Android
#### Prepare
* [Android SDK](https://developer.android.com/studio)
#### Compile
```
./make.dart android
```
#### Output
* `$VERSION.aab` an application bundle
* `$VERSION.apk` an application package

### Linux
#### Prepare
* Linux (maybe some other Unixes work, too)
* Clang
* CMake
* GTK3 headers
* Ninja
* pkg-config

(pre-installed if you installed Flutter through snap)
(if you use Debian\*, you can apt install:
`clang cmake libgtk-3-dev ninja-build pkg-config`)
#### Compile
```
./make.dart linux
```
#### Output
* `$VERSION.linux/` a folder containing the Amplessimus binary and all deps

### iOS
#### Prepare
* macOS
* Xcode
#### Compile
```
./make.dart ios
```
#### Output
* `$VERSION.ipa` an unsigned iOS 12.2+ app

### macOS
#### Prepare
* macOS
* Xcode
#### Compile
```
./make.dart mac
```
#### Output
* `$VERSION.dmg` an installer image for macOS 10.15+

### Windows
#### Prepare
* Windows
* Visual Studio
#### Compile
```
dart run make.dart win
```
#### Output
* `$VERSION.win/`
