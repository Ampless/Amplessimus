#!/bin/sh
mkdir -p /usr/local/var/www/amplissimus
cd amplissimus
make || exit 1
cd ..
echo moving
mv -f amplissimus/bin "/usr/local/var/www/amplissimus/$1"
