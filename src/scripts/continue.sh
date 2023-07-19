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
		printf "CIRCLE_CONTINUATION_KEY is required. Make sure setup workflows are enabled.\n"
		printf "This Job is designed to be used with the Orb Development Kit.\n"
		exit 1
	fi

	if [ -z "${ORB_VAL_CIRCLECI_API_HOST}" ]; then
		printf "ORB_VAL_CIRCLECI_API_HOST is required.\n"
		printf "If you are using CircleCI Cloud, use default value or set https://circleci.com.\n"
		exit 1
	fi

	if ! command -v curl >/dev/null; then
		printf "curl is required to use this command\n"
		exit 1
	fi

	if ! command -v jq >/dev/null; then
		printf "jq is required to use this command\n"
		exit 1
	fi

	if ! command -v yq >/dev/null; then
		printf "yq is required to use this command\n"
		exit 1
	fi

	if [ "$ORB_VAL_INJECT_ORB" == 1 ] && [ ! -f "${ORB_DIR}/${ORB_FILE}" ]; then
		printf "Inject orb is enabled, but %s is not found in %s.\n" "${ORB_FILE}" "${ORB_DIR}"
	fi
}

# Inject orb source into the configuration
injectOrb() {
	printf "Injecting orb source into configuration.\n"
	ORB_SOURCE="${ORB_DIR}/${ORB_FILE}"
	export ORB_SOURCE
	# NOTE: load function from yq is only available from v4.x
	MODIFIED_CONFIG="$(yq '.orbs.[env(ORB_VAL_ORB_NAME)] = load(env(ORB_SOURCE))' "${ORB_VAL_CONTINUE_CONFIG_PATH}")"
	printf "Modified config:\n\n"
	printf "%s" "${MODIFIED_CONFIG}"
	printf "%s" "${MODIFIED_CONFIG}" >"/tmp/circleci/modified/${ORB_FILE}"
	export MODIFIED_CONFIG_PATH="/tmp/circleci/modified/${ORB_FILE}"
	printf "\n\n"
}

# Continue the pipeline using the modified configuration
continuePipeline() {
	# Escape the config as a JSON string.
	jq -Rs '.' "${MODIFIED_CONFIG_PATH:-$ORB_VAL_CONTINUE_CONFIG_PATH}" >/tmp/circleci/config-string.json
	jq -n \
		--arg continuation "$CIRCLE_CONTINUATION_KEY" \
		--slurpfile config /tmp/circleci/config-string.json \
		'{"continuation-key": $continuation, "configuration": $config|join("\n")}' >/tmp/circleci/continue_post.json

	# Continue the pipeline
	printf "Continuing pipeline...\n"
	RESPONSE=$(
		curl \
			-s \
			-o /dev/stderr \
			-w '%{http_code}' \
			-XPOST \
			-H "Content-Type: application/json" \
			-H "Accept: application/json" \
			--data @/tmp/circleci/continue_post.json \
			"${ORB_VAL_CIRCLECI_API_HOST}/api/v2/pipeline/continue"
	)
	# Check if the pipeline was successfully continued
	if [[ "$RESPONSE" -eq 200 ]]; then
		printf "Pipeline successfully continued.\n"
	else
		printf "ERROR: Response code %s\n" "$RESPONSE"
		printf "Failed to continue pipeline. Attempt to retry the pipeline, if the problem persists please open an issue on the Orb-Tools Orb repository: https://github.com/CircleCI-Public/orb-tools-orb\n"
		exit 1
	fi

	# [[ $(curl \
	# 	-s \
	# 	-o /dev/stderr \
	# 	-w '%{http_code}' \
	# 	-XPOST \
	# 	-H "Content-Type: application/json" \
	# 	-H "Accept: application/json" \
	# 	--data @/tmp/circleci/continue_post.json \
	# 	"${ORB_VAL_CIRCLECI_API_HOST}/api/v2/pipeline/continue") -eq 200 ]] || printf "Failed to continue pipeline. Attempt to retry the pipeline, if the problem persists please open an issue on the Orb-Tools Orb repository: https://github.com/CircleCI-Public/orb-tools-orb\n" >&2 && exit 1
}

# Print completion message
printComplete() {
	printf "Continuation successful!\n"
	printf "Your orb will now be tested in the next workflow.\n"
	# shellcheck disable=SC2153
	printf "View the full pipeline progress: %s/pipelines/%s/%s/%s/%s\n" "${ORB_VAL_CIRCLECI_APP_HOST}" "${ORB_VAL_PIPELINE_VCS_TYPE}" "${CIRCLE_PROJECT_USERNAME}" "${CIRCLE_PROJECT_REPONAME}" "${ORB_VAL_PIPELINE_NUMBER}"

}

# ========================
setup
checkRequirements
if [ "$ORB_VAL_INJECT_ORB" == 1 ]; then
	injectOrb
fi
continuePipeline
printComplete
