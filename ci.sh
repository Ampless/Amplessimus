#!/bin/sh
cd amplissimus
make || exit 1
cd ..
echo moving
mv -f amplissimus/bin/* /usr/local/var/www/
