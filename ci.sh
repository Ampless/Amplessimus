#!/bin/sh
cd amplissimus
make || exit 1
cd ..
mv -f amplissimus/bin/* /usr/local/var/www/
