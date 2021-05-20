setup() {
	REVIEW_TEST_DIR="./"
	CONFIG_TAG_SELECTION=$(cat ${REVIEW_TEST_DIR}/.circleci/test_and_deploy.yml | yq -r '.workflows.test_and_deploy.jobs | map(select(type == "object"))[]."orb-tools-alpha/publish-release".tag' )
	declare -a SKIPPED_REVIEW_CHECKS
}

@test "RC001: Verify the intended tag is a proper semver tag" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC001" ]]; then
    	skip
	fi
	SEMVER_REGEX="[0-9]+\.[0-9]+\.[0-9]+"

	echo 'The "tag" parameter of the "publish-release" job must be a semver value.'
	[[ $CONFIG_TAG_SELECTION =~ $SEMVER_REGEX ]]
}

@test "RC002: Include source_url in @orb.yml" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC002" ]]; then
    	skip
	fi
	result=$(cat ${REVIEW_TEST_DIR}src/@orb.yml | yq '.display.source_url' )

	echo 'Set a value for "source_url" under the "display" key in "@orb.yml"'
	[[ ! $result = null ]]
}

@test "RC003: Verify intended tag doesn't already exist in git" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC003" ]]; then
    	skip
	fi
	if git rev-parse $CONFIG_TAG_SELECTION >/dev/null 2>&1 ; then
		echo "This tag already exists in Git. Orb tags are immutable. Select a different tag"
		exit 1
	fi
}

@test "RC004: All components (jobs, commands, executors, examples) must have descriptions" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC004" ]]; then
    	skip
	fi
	for i in $(find ${REVIEW_TEST_DIR}src/jobs ${REVIEW_TEST_DIR}src/examples ${REVIEW_TEST_DIR}src/commands ${REVIEW_TEST_DIR}src/executors -name "*.yml" 2>/dev/null); do
		ORB_ELEMENT_DESCRIPTION=$(cat $i | yq '.description')
		if [[ $ORB_ELEMENT_DESCRIPTION == null || $ORB_ELEMENT_DESCRIPTION == '""' ]]; then
			echo
			echo "Orb component ${i} is missing a description"
			echo "Orb components are not invalid without descriptions, but these descriptions appear on the Orb Registry for documentation and provide a better experience."
			echo "Check all orb components for descriptions."
			exit 1
		fi
	done
}