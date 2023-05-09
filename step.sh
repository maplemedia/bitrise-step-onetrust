#!/bin/bash

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
#  envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.

#!/usr/bin/env bash

set -e

#####################

# OneTrust OAuth Client ID
if [[ -z "$onetrust_oauth_client_id" ]]; then
  echo "Missing OneTrust OAuth Client ID"
  exit 1
fi

# OneTrust OAuth Client Secret
if [[ -z "$onetrust_oauth_client_secret" ]]; then
  echo "Missing OneTrust OAuth Client Secret"
  exit 1
fi

# OneTrust App ID
if [[ -z "$onetrust_application_id" ]]; then
  echo "Missing OneTrust Application ID"
  exit 1
fi

# OneTrust App Platform
supported_platforms=("ANDROID" "IOS")
IFS=','; supported_platforms_string="${supported_platforms[*]}"; unset IFS
if [[ -z "$onetrust_application_platform" ]]; then
  echo "Missing OneTrust Application Platform. Supported values: $supported_platforms_string"
  exit 1
fi

if [[ " ${supported_platforms[@]} " =~ " $onetrust_application_platform " ]]; then
    : # Do nothing if input matches a supported value
else
    echo "Unsupported OneTrust Application Platform: $onetrust_application_platform. Supported values: $supported_platforms_string"
    exit 1
fi

# OneTrust Upload URL
if [[ -z "$onetrust_upload_url" ]]; then
  echo "Missing OneTrust Upload URL"
  exit 1
fi

# App file path
if [[ -z "$app_file_path" ]]; then
  echo "Missing App file path"
  exit 1
fi


#####################


# Request access token
response=$(curl -s -X POST \
  -H "accept: application/json" \
  -H "content-type: multipart/form-data" \
  -F "grant_type=client_credentials" \
  -u "$onetrust_oauth_client_id:$onetrust_oauth_client_secret" \
  "https://app.onetrust.com/api/access/v1/oauth/token")

# Check if access token was obtained successfully
if [[ $? -ne 0 ]]; then
  echo "Failed to retrieve access token."
  exit 1
fi

# Check if the response contains an error
error=$(echo "$response" | jq -r '.error')
error_description=$(echo "$response" | jq -r '.error_description')

if [[ "$error" != "null" ]]; then
  echo "Failed to retrieve access token. Error: $error"
  if [[ "$error_description" != "null" ]]; then
    echo "Error Description: $error_description"
  fi
  exit 1
fi

# Parse access token from the response
access_token=$(echo "$response" | jq -r '.access_token')

# Check if access token is empty
if [[ -z "$access_token" ]]; then
  echo "Access token not found in the response"
  exit 1
fi


#####################


echo "Uploading App file... $app_file_path"

# Upload app for scaning
response=$(curl -s -X POST \
  -H "Authorization: Bearer $access_token" \
  -H "Content-Type: multipart/form-data" \
  -H "Content-Type: application/json" \
  -F "file=@$app_file_path" \
  -F "dataFields={\"appId\": \"$onetrust_application_id\", \"platform\": \"$onetrust_application_platform\"}" \
  "$onetrust_upload_url")

# Check if the response contains the request ID
request_id=$(echo "$response" | sed -n 's/.*"requestId":"\([^"]*\)".*/\1/p')

if [[ -n "$request_id" ]]; then
  echo "Upload successful. Request ID: $request_id"
else
  echo "Upload failed. Response: $response"
  exit 1
fi

