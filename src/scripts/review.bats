setup() {
	REVIEW_TEST_DIR="."
	CONFIG_TAG_SELECTION=$(cat ${REVIEW_TEST_DIR}/.circleci/test_and_deploy.yml | yq -r '.workflows.test_and_deploy.jobs | map(select(type == "object"))[]."orb-tools-alpha/publish-release".tag' )
	echo "${CONFIG_TAG_SELECTION}"
	declare -a SKIPPED_REVIEW_CHECKS
}

@test "RC001: Ensure the specified tag is a proper semver tag" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC001" ]]; then
    	skip
	fi
	SEMVER_REGEX="[0-9]+\.[0-9]+\.[0-9]+"

	echo 'The "tag" parameter of the "publish-release" job must be a semver value.'
	[[ $CONFIG_TAG_SELECTION =~ $SEMVER_REGEX ]]
}

@test "RC002: Include Source URL" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC002" ]]; then
    	skip
	fi
	result=$(cat ${REVIEW_TEST_DIR}/src/@orb.yml | yq '.display.source_url' )

	echo 'Set a value for "source_url" under the "display" key in "@orb.yml"'
	[[ ! $result = null ]]
}

@test "RC003: Verify tag doesn't exist" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC003" ]]; then
    	skip
	fi
	if git rev-parse $CONFIG_TAG_SELECTION >/dev/null 2>&1 ; then
		echo "This tag already exists in Git. Orb tags are immutable. Select a different tag"
		exit 1
	fi
}