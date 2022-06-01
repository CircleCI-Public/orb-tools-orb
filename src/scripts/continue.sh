#!/bin/bash
if [ -z "${CIRCLE_CONTINUATION_KEY}" ]; then
	echo "CIRCLE_CONTINUATION_KEY is required. Make sure setup workflows are enabled."
	echo "This Job is designed to be used with the Orb Development Kit."
	exit 1
fi
if [ -z "${CIRCLECI_API_HOST}" ]; then
	echo "CIRCLECI_API_HOST is required."
	echo "If you are using CircleCI Cloud, use default value or set https://circleci.com."
	exit 1
fi

if ! command -v curl; then
	echo "curl is required to use this command"
	exit 1
fi

if ! command -v jq; then
	echo "jq is required to use this command"
	exit 1
fi

mkdir -p /tmp/circleci
rm -rf /tmp/circleci/continue_post.json

# Escape the config as a JSON string.

jq -Rs '.' "$ORB_PARAM_CONTINUE_CONFIG_PATH" >/tmp/circleci/config-string.json

jq -n \
	--arg continuation "$CIRCLE_CONTINUATION_KEY" \
	--slurpfile config /tmp/circleci/config-string.json \
	'{"continuation-key": $continuation, "configuration": $config|join("\n")}' >/tmp/circleci/continue_post.json

[[ $(curl \
	-o /dev/stderr \
	-w '%{http_code}' \
	-XPOST \
	-H "Content-Type: application/json" \
	-H "Accept: application/json" \
	--data @/tmp/circleci/continue_post.json \
	"${CIRCLECI_API_HOST}/api/v2/pipeline/continue") -eq 200 ]]

echo "Continuation successful!"
echo "Your newly published development orb will now be tested in the next workflow."
echo "View the full pipeline progress: ${CIRCLECI_APP_HOST}/pipelines/${PIPELINE_VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${PIPELINE_VCS_TYPE}/${PIPELINE_NUMBER}"
