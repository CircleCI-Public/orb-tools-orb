setup() {
	REVIEW_TEST_DIR="./"
	declare -a SKIPPED_REVIEW_CHECKS
}

@test "RC001: Include source_url in @orb.yml" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC001" ]]; then
    	skip
	fi
	result=$(cat ${REVIEW_TEST_DIR}src/@orb.yml | yq '.display.source_url' )

	echo 'Set a value for "source_url" under the "display" key in "@orb.yml"'
	[[ ! $result = null ]]
}

@test "RC002: All components (jobs, commands, executors, examples) must have descriptions" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC002" ]]; then
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

@test "RC003: All production-ready orbs should contain at least one usage example." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC003" ]]; then
    	skip
	fi
	ORB_ELEMENT_EXAMPLE_COUNT=$(find ${REVIEW_TEST_DIR}/src/examples/*.yml -type f | wc -l | xargs)
	if [ "$ORB_ELEMENT_EXAMPLE_COUNT" -gt 0 ]; then
		echo
		echo "This orb appears to be missing a usage example."
		echo "Add examples under `${REVIEW_TEST_DIR}src/examples` to document how to use the orb for any available use cases."
	fi
}

@test "RC004: Usage example names shoud be descriptive." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC004" ]]; then
    	skip
	fi
	for i in $(find ${REVIEW_TEST_DIR}/src/examples/*.yml -type f); do
		if [[ $i =~ "example" ]]; then
			echo
			echo "Usage example file name ${i} contains the word 'example'."
			echo "Usage example file names should be descriptive and not contain the word 'example'."
			exit 1
		fi
	done
}

@test "RC005: Orb description appears short." {
if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC005" ]]; then
    	skip
	fi
	ORB_ELEMENT_DESCRIPTION=$(cat ${REVIEW_TEST_DIR}src/@orb.yml | yq '.description')
	if [[ ${#ORB_ELEMENT_DESCRIPTION} -lt 64 ]]; then
		echo
		echo "Orb description appears short."
		echo "Use the orb description to help users find your orb via search. Try describing what use-case this orb solves for."
		exit 1
	fi
}