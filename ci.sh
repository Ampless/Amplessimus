#!/bin/sh

# create a github release
# args:
#  commitid (1)
#  name     (2)
gh_create_release() {
        echo "[GitHub] Creating release: $2" >&2
        RAW="$(curl -X POST '-#' -u "$(cat /etc/ampci.creds)" \
                -H "Accept: application/vnd.github.v3+json" \
                --data "{
                         \"tag_name\": \"$2\",
                         \"target_commitish\": \"$1\",
                         \"name\": \"$2\",
                         \"body\": \"This is an automatic release by the ci.\\n\\n###### Changelog\\n\\n\\n###### Related Issues\\n\\n\\n###### Known Bugs\\n\",
                         \"draft\": false,
                         \"prerelease\": true
                        }" \
               https://api.github.com/repos/Ampless/Amplessimus/releases)"
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
        curl -X POST -'#' -u "$(cat /etc/ampci.creds)" \
                -H "Accept: application/vnd.github.v3+json" \
                -H "Content-Type: application/octet-stream" \
                --data-binary "@$2" "$(echo "$1" | sed "s/$/?name=$2/")"
        echo
        echo "[GitHub] Done uploading: $2"
}

flutter_update() {
        flutter channel master
        flutter upgrade
        flutter config --enable-web --enable-macos-desktop
}

update_altstore() {
        cd
        [ ! -d ampless.chrissx.de ] && git clone https://github.com/Ampless/ampless.chrissx.de
        cd ampless.chrissx.de
        git pull
        cd altstore
        sed -E 's/^ *"version": ".*",$/      "version": "'"$version_name"'",/' alpha.json | \
        sed -E 's/^ *"versionDate": ".*",$/      "versionDate": "'"$(date -u '+%FT%T')+00:00"'",/' | \
        sed -E 's/^ *"versionDescription": ".*",$/      "versionDescription": "As of '"$(date)"'",/' | \
        sed -E 's/^ *"downloadURL": ".*",$/      "downloadURL": "https:\/\/github.com\/Ampless\/Amplessimus\/releases\/download\/'"$version_name"'\/'"$version_name"'.ipa",/' > temp.json
        mv temp.json alpha.json
        git add alpha.json
        git commit -m "automatic ci update to amplessimus ios alpha version $version_name"
        git push
}

output() {
        mv -f bin "$output_dir"

        [ ! -f /etc/ampci.creds ] && { echo "No GitHub creds found." ; exit 1 ; }
        cd "$output_dir"
        upload_url="$(gh_create_release $commitid $version_name)"
        for fn in * ; do
                gh_upload_binary "$upload_url" "$fn"
        done
}

main() {
        git stash
        git pull

        commitid=$(git rev-parse @)
        raw_version="$(head -n 1 Makefile | cut -d' ' -f3)"
        version_name="$raw_version.$(echo $commitid | cut -c 1-7)"
        output_dir="/usr/local/var/www/amplissimus/$version_name"
        mkdir -p bin
        {
                echo "Building $version_name..."
                flutter_update

                mkdir -p /usr/local/var/www/amplissimus

                make ci || { make cleanartifacts rollbackversions ; output ; exit 1 ; }
                make mac || { make cleanartifacts rollbackversions ; }
        } 2>&1 | tee bin/ci.log

        output

        update_altstore
}

main
