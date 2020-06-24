#!/bin/sh
flutter channel master
flutter upgrade
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
mkdir -p /usr/local/var/www/amplissimus
cd amplissimus
flutter pub cache repair # this might fix some stupid problems with shared_preferences_macos
make ci || { make cleanartifacts rollbackversions ; exit 1 ; }
cp -rf bin "/usr/local/var/www/amplissimus/$1"
cd bin
tar cJf "/usr/local/var/www/amplissimus/$1/$2.tar.xz" *
rm -rf *
cd ../..
