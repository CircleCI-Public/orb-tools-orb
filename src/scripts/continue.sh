#!/bin/bash

ORB_DIR=${ORB_VAL_ORB_DIR%/}
ORB_FILE=${ORB_VAL_ORB_FILE_NAME#/}

# Create temporary directories and files
setup() {
	mkdir -p /tmp/circleci/modified
	rm -rf /tmp/circleci/continue_post.json
}

# Check for required environment variables and commands
checkRequirements() {
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

	if ! command -v curl >/dev/null; then
		echo "curl is required to use this command"
		exit 1
	fi

	if ! command -v jq >/dev/null; then
		echo "jq is required to use this command"
		exit 1
	fi

	if ! command -v yq >/dev/null; then
		echo "yq is required to use this command"
		exit 1
	fi

	if [ "$ORB_VAL_INJECT_ORB" == 1 ] && [ ! -f "${ORB_DIR}/${ORB_FILE}" ]; then
		echo "Inject orb is enabled, but ${ORB_FILE} is not found in ${ORB_DIR}."
	fi
}

# Inject orb source into the configuration
injectOrb() {
	ORB_SOURCE="$(cat "${ORB_DIR}/${ORB_FILE}")"
	export ORB_SOURCE
	MODIFIED_CONFIG="$(yq '.orbs.[env(ORB_VAL_ORB_NAME)] = env(ORB_SOURCE)' "${ORB_VAL_CONTINUE_CONFIG_PATH}")"
	echo "Orb Source has been injected into the config."
	echo "Modified config:"
	echo
	printf "%s" "${MODIFIED_CONFIG}"
	printf "%s" "${MODIFIED_CONFIG}" >"/tmp/circleci/modified/${ORB_FILE}"
	export MODIFIED_CONFIG_PATH="/tmp/circleci/modified/${ORB_FILE}"
	echo
}

# Continue the pipeline using the modified configuration
continuePipeline() {
	# Escape the config as a JSON string.
	jq -Rs '.' "${MODIFIED_CONFIG_PATH:-$ORB_VAL_CONTINUE_CONFIG_PATH}" >/tmp/circleci/config-string.json
	jq -n \
		--arg continuation "$CIRCLE_CONTINUATION_KEY" \
		--slurpfile config /tmp/circleci/config-string.json \
		'{"continuation-key": $continuation, "configuration": $config|join("\n")}' >/tmp/circleci/continue_post.json

	[[ $(curl \
		-s \
		-o /dev/stderr \
		-w '%{http_code}' \
		-XPOST \
		-H "Content-Type: application/json" \
		-H "Accept: application/json" \
		--data @/tmp/circleci/continue_post.json \
		"${CIRCLECI_API_HOST}/api/v2/pipeline/continue") -eq 200 ]] || echo "Failed to continue pipeline. Attempt to retry the pipeline, if the problem persists please open an issue on the Orb-Tools Orb repository: https://github.com/CircleCI-Public/orb-tools-orb" >&2 && exit 1
}

# Print completion message
printComplete() {
	echo "Continuation successful!"
	echo "Your orb will now be tested in the next workflow."
	# shellcheck disable=SC2153
	echo "View the full pipeline progress: ${CIRCLECI_APP_HOST}/pipelines/${PIPELINE_VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/${PIPELINE_NUMBER}"
}

# ========================
setup
checkRequirements
if [ "$ORB_VAL_INJECT_ORB" == 1 ]; then
	injectOrb
fi
continuePipeline
printComplete
