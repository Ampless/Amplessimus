#!/bin/bash
# This is for Cydia: http://www.saurik.com/id/7

mkdir -p tmp2deb/DEBIAN
grep -v "^#" control.def | \
  sed "s/\$VERSION/$1/" | \
  sed "s/\$SIZE/`du -sk build/ios/Release-iphoneos/Runner.app | awk '{ print $1 }'`/" | \
  sed "s/\$ARCH/iphoneos-arm/" > tmp2deb/DEBIAN/control

mkdir -p tmp2deb/Applications
cp -rp build/ios/Release-iphoneos/Runner.app tmp2deb/Applications/

COPYFILE_DISABLE= COPY_EXTENDED_ATTRIBUTES_DISABLE= dpkg-deb -Sextreme -z9 --build tmp2deb bin/$1.deb

rm -rf tmp2deb
exit 0
