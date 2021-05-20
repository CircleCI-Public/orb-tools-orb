#!/bin/bash
if [ -z "${CIRCLE_CONTINUATION_KEY}" ]; then
	echo "CIRCLE_CONTINUATION_KEY is required. Make sure setup workflows are enabled."
	echo "This Job is designed to be used with the Orb Development Kit."
	exit 1
fi
if ! which curl > /dev/null; then
	echo "curl is required to use this command"
	exit 1
fi

if ! which jq > /dev/null; then
	echo "jq is required to use this command"
	exit 1
fi

mkdir -p /tmp/circleci
rm -rf /tmp/circleci/continue_post.json

# Escape the config as a JSON string.

jq -Rs '.' ".circleci/test_and_deploy.yml" > /tmp/circleci/config-string.json

jq -n \
	--arg continuation "$CIRCLE_CONTINUATION_KEY" \
	--slurpfile config /tmp/circleci/config-string.json \
	'{"continuation-key": $continuation, "configuration": $config|join("\n")}' > /tmp/circleci/continue_post.json

[[ $(curl \
		-o /dev/stderr \
		-w '%{http_code}' \
		-XPOST \
		-H "Content-Type: application/json" \
		-H "Accept: application/json"  \
		--data @/tmp/circleci/continue_post.json \
		"https://circleci.com/api/v2/pipeline/continue") \
   -eq 200 ]]