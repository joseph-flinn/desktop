#!/bin/bash

# Grab all assets from the release
#   - Step 1: Get ids for all latest*.yml assets
#   - Step 2: Get the assets via their ids
#   - Step 3: Manually change assets
#   - Step 4: Update release with new assets

TOKEN="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"

curl \
    -H "Authorization:token $TOKEN" \
    -H "Accept:application/vnd.github.v3+json" \
    https://api.github.com/repos/joseph-flinn/desktop/releases \
    | jq -r ' .[] | select( .tag_name == "v1.27.9")' > release.json

echo "=====RELEASE====="
echo Release:
#cat release.json

RELEASE_UPLOAD_URL=$(cat release.json | jq -r ' .upload_url ' | cut -d { -f 1)
cat release.json | jq -rc ' .assets[] | select( .name | test("latest.*[yml|json]")) | {name: .name,  url: .url, content_type: .content_type}' > release_assets.json

echo "=====ASSETS====="
echo Release Upload URL: $RELEASE_UPLOAD_URL
echo Release Assets:
cat release_assets.json

while read -r asset; do 
    echo -e "\n================"
    echo "[*] Asset: $asset"
    FILE_NAME=$(echo $asset | jq -r '.name')
    FILE_URL=$(echo $asset | jq -r '.url')
    FILE_CONTENT_TYPE=$(echo $asset | jq -r '.content_type')
    echo "[*] Asset name: $FILE_NAME"
    echo "[*] Asset url: $FILE_URL"
    echo "[*] Asset content_type: $FILE_CONTENT_TYPE"
    echo "[+] Grabbing asset..."
    curl \
        -L -H "Authorization:token $TOKEN" \
        -H "Accept: application/octet-stream" \
        $FILE_URL --output  $FILE_NAME

        #-v -H "Authorization:token $TOKEN" \
        #-H "Accept: $FILE_CONTENT_TYPE" \

    NEW_FILE_SIZE=$(wc -c < $FILE_NAME | xargs)
    echo "New file size: $NEW_FILE_SIZE"
    echo "New file name: $FILE_NAME"
    echo "================"

    #echo "Deleting remote asset..."
    #curl \
    #    -v -X DELETE \
    #    -H "Authorization:token $TOKEN" \
    #    -H "Accept: application/vnd.github.v3+json" \
    #    $FILE_URL

    echo "[+] Testing code"
    NEW_FILE_NAME="manual-$FILE_NAME"
    cp $FILE_NAME $NEW_FILE_NAME

    echo "[+] Pushing updated asset..."
    curl \
        -X POST \
        -H "Authorization:token $TOKEN" \
        -H "Content-Type: $FILE_CONTENT_TYPE" \
        -H "Content-Length: $NEW_FILE_SIZE" \
        --data-binary @$FILE_NAME \
        "$RELEASE_UPLOAD_URL?name=$NEW_FILE_NAME" --http1.1

done < release_assets.json
