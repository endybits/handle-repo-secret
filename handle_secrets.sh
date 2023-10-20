#!/bin/bash
echo Hello Secret

export GITHUB_TOKEN=$( cat private_access_token.txt ) #you can use other method for get your PAT
export REPO_OWNER="endybits"
export REPO_NAME="your-repo"
export SECRET_NAME="SECRET_FROM_BASH"
export NEW_SECRET_VALUE="super_secret_value_from_bash"
export NEW_SECRET_ENCRYPTED=$( echo $NEW_SECRET_VALUE | base64 ) # For create or update a secret it is necessary to encode its value.
echo $NEW_SECRET_ENCRYPTED

## Getting repo public key
#{ "key_id": "343424342323232", "key": "EXAMPLEuwns3MSG/EXAMPLEUn8a1sdffrHI=" }
export REPO_KEY_ID=$( curl -L \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github.v3+json" \
              "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key" \
              | jq -r '.key_id' )         # extract key_id from the json format response
echo $REPO_KEY_ID


### CREATE OR UPDATE SECRET
curl -L \
  -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d '{"encrypted_value":"'$NEW_SECRET_ENCRYPTED'", "key_id":"'$REPO_KEY_ID'"}' \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$SECRET_NAME"


### LIST SECRETS NAMES
curl -L \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/secrets"
