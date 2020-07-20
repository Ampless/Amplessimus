#!/bin/sh
[ -z $DEB ] && DEB=/dev/null
[ -z $BUILD_DIR ] && BUILD_DIR=/dev/null
[ -z $VERSION ] && VERSION=0.0.0-1
[ -z $INPUT ] && { echo 'No input specified.' ; exit 1 ; }
[ -z $OUTPUT ] && { echo 'No output specified.' ; exit 1 ; }
ISIZE=$(du -sk $BUILD_DIR | awk '{ print $1 }')
SIZE=$(ls -l $DEB | awk '{ print $5 }')
MD5=$(md5sum $DEB | awk '{ print $1 }')
grep -v "^#" $INPUT | \
    sed "s/0.0.0-1/$VERSION/" | \
    sed "s/\$ISIZE/$ISIZE/" | \
    sed "s/\$SIZE/$SIZE/" | \
    sed "s/\$MD5/$MD5/" | \
    sed "s/\$ARCH/iphoneos-arm/" > $OUTPUT
exit 0
