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
                        \"body\": \"This is an automatic release by the ci.\\n\\n###### Changelog\\n\\n\\n###### Known Problems\\n\\n\",
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
                --data-binary @$2 "$(echo "$1" | sed "s/$/?name=$2/")"
        echo
        echo "[GitHub] Done uploading: $2"
}

update_altstore() {
        cd
        [ -d ampless.chrissx.de ] || git clone https://github.com/Ampless/ampless.chrissx.de
        cd ampless.chrissx.de/altstore
        git pull
        sed -E 's/^ *"version": ".*",$/      "version": "'"$version_name"'",/' alpha.json | \
        sed -E 's/^ *"versionDate": ".*",$/      "versionDate": "'"$(date -u '+%FT%T')+00:00"'",/' | \
        sed -E 's/^ *"versionDescription": ".*",$/      "versionDescription": "'"$(date '+%d.%m.%y %H:%M')"'",/' | \
        sed -E 's/^ *"downloadURL": ".*",$/      "downloadURL": "https:\/\/github.com\/Ampless\/Amplessimus\/releases\/download\/'"$version_name"'\/'"$version_name"'.ipa",/' > temp.json
        mv temp.json alpha.json
        git add alpha.json
        git commit -m "automatic ci update to amplessimus ios alpha version $version_name"
        git push
}

output() {
        mv -f bin "$output_dir"

        [ -f /etc/ampci.creds ] || { echo "No GitHub creds found." ; exit 1 ; }
        cd "$output_dir"
        upload_url="$(gh_create_release $commitid $version_name)"
        for fn in * ; do
                gh_upload_binary "$upload_url" "$fn" &
        done
}

main() {
        git stash
        git pull

        mkdir -p bin

        commitid=$(git rev-parse @)
        version_name="$(dart run make.dart ver).$(git rev-list @ --count)"
        output_dir="/usr/local/var/www/amplessimus/$version_name"

        {
                mkdir -p /usr/local/var/www/amplessimus

                # echo "Running tests..."
                # flutter test

                echo "[AmpCI][$(date)] Running the Dart build system for $version_name."

                dart run make.dart ci
        } 2>&1 | tee bin/ci.log

        (update_altstore) &

        output
}

main
