#!/bin/sh

# create a github release
# args:
#  commitid (1)
#  name     (2)
gh_create_release() {
        echo "[GitHub] Creating release: $2" >&2
        RAW="$(curl -X POST -u "$(cat /etc/ampci.creds)" \
                -H "Accept: application/vnd.github.v3+json" \
                --data "{
                         \"tag_name\": \"$2\",
                         \"target_commitish\": \"$1\",
                         \"name\": \"$2\",
                         \"body\": \"This is an automatic release by the ci.\\n\\n###### Changelog\\n\\n\\n###### Related Issues\\n\\n\\n###### Known Bugs\\n\",
                         \"draft\": false,
                         \"prerelease\": true
                        }" \
                                https://api.github.com/repos/Amplissimus/Amplissimus/releases)"
        UPLOAD_URL=$(echo "$RAW" | grep '"upload_url":' | head -n 1 | cut -d: -f2- | sed 's/^.*"\(.*\)".*$/\1/' | sed 's/{?name,label}//')
        echo "[GitHub] Created release: $UPLOAD_URL" >&2
        echo "$UPLOAD_URL"
}

# upload a file to a github release
# args:
#  output of gh_create_release (1)
#  file                        (2)
gh_upload_binary() {
        echo "[GitHub] Uploading binary: $2"
        curl -X POST -u "$(cat /etc/ampci.creds)" \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Content-Type: application/octet-stream" \
                --data-binary "@$2" "$(echo "$1" | sed "s/$/?name=$2/")"
        echo
        echo "[GitHub] Done uploading: $2"
}

flutter channel master
flutter upgrade
flutter config --enable-web --enable-macos-desktop

mkdir -p /usr/local/var/www/amplissimus
cd amplissimus
make ci || { make cleanartifacts rollbackversions ; exit 1 ; }
make mac || { make cleanartifacts rollbackversions ; }

commitid=$(git rev-parse @)
date=$(date +%Y_%m_%d-%H_%M_%S)
raw_version="$(head -n 1 Makefile | cut -d' ' -f3)"
version_name="$raw_version.$(echo $commitid | cut -c 1-4)"
echo "$version_name"
output_dir="/usr/local/var/www/amplissimus/$version_name"

cp -rf bin "$output_dir"
rm -rf bin/*
cd ..

[ ! -f /etc/ampci.creds ] && { echo "No GitHub creds found." ; exit 1 ; }
cd $output_dir
upload_url="$(gh_create_release $commitid $version_name)"
for fn in * ; do
        gh_upload_binary "$upload_url" "$fn"
done

cd ~/amplus.chrissx.de/altstore
sed -E 's/^      "version": "[0-9]+.[0-9]+.[0-9]+.[0-9a-f]{4}",$/      "version": "'"$version_name"'",/' alpha.json | \
sed -E 's/^      "versionDate": "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{2}:[0-9]{2}",$/      "versionDate": "'"$(date '+%FT%T%:z')"'",/' | \
sed -E 's/^      "downloadURL": "https://github.com/Amplissimus/Amplissimus/releases/download/.+?/.+?.ipa",$/      "downloadURL": "https://github.com/Amplissimus/Amplissimus/releases/download/'"$version_name"'/'"$raw_version"'.ipa",/' > temp.json
mv temp.json alpha.json
git add alpha.json
git commit -m "automatic ci update to ios alpha version $version_name"
git push
