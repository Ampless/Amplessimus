#!/bin/bash
# This is for Cydia: http://www.saurik.com/id/7

set -e
set -u

DEB_BUILD_DIR=build/tmp
DEB_METADATA_DIR=$DEB_BUILD_DIR/DEBIAN
DEB_APP_DIR=$DEB_BUILD_DIR/Applications
DEB_DST=build/$1.deb

APPLICATION_DIR=build/ios/iphoneos/Runner.app
APPLICATION_SIZE=`du -sk $APPLICATION_DIR | awk '{ print $1 }'`

mkdir -p $DEB_METADATA_DIR
grep -v "^#" control.def | \
  sed "s/\$VERSION/$1/" | \
  sed "s/\$SIZE/$APPLICATION_SIZE/" | \
  sed "s/\$ARCH/iphoneos-arm/" > $DEB_METADATA_DIR/control

mkdir -p $DEB_APP_DIR
cp -rp $APPLICATION_DIR $DEB_APP_DIR/

export COPYFILE_DISABLE
export COPY_EXTENDED_ATTRIBUTES_DISABLE

dpkg-deb -Sextreme -z9 --build $DEB_BUILD_DIR $DEB_DST

rm -rf $DEB_BUILD_DIR
exit 0
