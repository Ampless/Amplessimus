#!/bin/sh
flutter channel master
flutter upgrade
flutter config --enable-web --enable-windows-desktop --enable-macos-desktop --enable-linux-desktop
mkdir -p /usr/local/var/www/amplissimus
cd amplissimus
#flutter pub cache repair # this might fix some stupid problems with shared_preferences_macos
make ci || { make cleanartifacts rollbackversions ; exit 1 ; }
commitid=$(git rev-parse @)
date=$(date +%Y_%m_%d-%H_%M_%S)
output_dir=$date-$commitid
cp -rf bin "/usr/local/var/www/amplissimus/$output_dir"
cd bin
tar cf "/usr/local/var/www/amplissimus/$output_dir/$commitid.tar" *
rm -rf *
cd ../..
