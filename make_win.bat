rem This script is quite bad and you probably shouldn't use it, but if you want easy Windows builds, you kinda have to use it.
mkdir bin
flutter channel master
flutter upgrade
flutter config --enable-windows-desktop
flutter build windows --release --suppress-analytics --split-debug-info=debug_symbols --obfuscate
move build\windows\x64\Release\Runner bin\amplessimus.win
