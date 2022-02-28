setup() {
	REVIEW_TEST_DIR="./"
	declare -a SKIPPED_REVIEW_CHECKS
}

@test "RC001: Include source_url in @orb.yml" {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC001" ]]; then
		skip
	fi
	result=$(cat ${REVIEW_TEST_DIR}src/@orb.yml | yq '.display.source_url')

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
	ORB_ELEMENT_EXAMPLE_COUNT=$(find ${REVIEW_TEST_DIR}src/examples/*.yml -type f 2>/dev/null | wc -l | xargs)
	if [ "$ORB_ELEMENT_EXAMPLE_COUNT" -lt 1 ]; then
		echo
		echo "This orb appears to be missing a usage example."
		echo "Add examples under $(${REVIEW_TEST_DIR}src/examples) to document how to use the orb for any available use cases."
		exit 1
	fi
}

@test "RC004: Usage example names shoud be descriptive." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC004" ]]; then
		skip
	fi
	for i in $(find ${REVIEW_TEST_DIR}/src/examples/*.yml -type f >/dev/null 2>&1); do
		if [[ $i =~ "example" ]]; then
			echo
			echo "Usage example file name ${i} contains the word 'example'."
			echo "Usage example file names should be descriptive and not contain the word 'example'."
			exit 1
		fi
	done
}

@test "RC005: Write a detailed orb description." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC005" ]]; then
		skip
	fi
	ORB_ELEMENT_DESCRIPTION=$(cat ${REVIEW_TEST_DIR}src/@orb.yml | yq '.description')
	if [[ ${#ORB_ELEMENT_DESCRIPTION} -lt 64 ]]; then
		echo
		echo "Orb description appears short (under 64 characters)."
		echo "Update the description in ${REVIEW_TEST_DIR}src/@orb.yml to provide a detailed description of the orb."
		echo "Use the orb description to help users find your orb via search. Try describing what use-case this orb solves for."
		exit 1
	fi
}

@test "RC006: Source URL should be valid." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC006" ]]; then
		skip
	fi
	SOURCE_URL=$(cat ${REVIEW_TEST_DIR}/src/@orb.yml | yq '.display.source_url')
	HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 $SOURCE_URL)
	if [[ $HTTP_RESPONSE -ne 200 ]]; then
		echo
		echo "Source URL: \"$SOURCE_URL\" is not reachable."
		echo "Check the Source URL for this orb."
		exit 1
	fi
}

@test "RC007: Home URL should be valid." {
	HOME_URL=$(cat ${REVIEW_TEST_DIR}/src/@orb.yml | yq '.display.home_url')
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC007" || "$HOME_URL" == "null" ]]; then
		skip
	fi
	HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 $HOME_URL)
	if [[ $HTTP_RESPONSE -ne 200 ]]; then
		echo
		echo "Home URL: \"$HOME_URL\" is not reachable."
		echo "Check the Home URL for this orb."
		exit 1
	fi
}

@test "RC008: All Run steps should contain a name." {
	if [[ " ${SKIPPED_REVIEW_CHECKS[@]} " =~ "RC008" ]]; then
		skip
	fi
	ERROR_COUNT=0
	for i in $(find ${REVIEW_TEST_DIR}src/jobs ${REVIEW_TEST_DIR}src/commands -name "*.yml" 2>/dev/null); do
		ORB_COMPONENT_STEPS_COUNT=$(cat $i | yq '[.steps.[] | .run] | length - 1')
		for j in $(seq 0 $ORB_COMPONENT_STEPS_COUNT); do

			ORB_COMPONENT_STEP=$(cat $i | yq "[.steps.[] | .run][$j]")
			ORB_COMPONENT_LINE_NUMBER=$(cat $i | yq "[.steps.[] | .run][$j] | line")
			ORB_COMPONENT_STEP_NAME=$(cat $i | yq '.steps[$j].run.name')
			if [[ $ORB_COMPONENT_STEP_NAME == null || $ORB_COMPONENT_STEP_NAME == '""' ]]; then
				echo "File: \"${i}\""
				echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
				echo ---
				cat $i | yq "[.steps.[] | .run][$j]"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			fi
		done
	done
	if [[ $ERROR_COUNT -gt 0 ]]; then
		echo
		echo "Components were found to contain \"run\" steps without a name."
		echo "Steps are not invalid without names, but the default used will be the command code, which can be long and confusing."
		echo "Consider adding a name to the step to make the output in the UI easier to read."
		echo "https://circleci.com/docs/2.0/configuration-reference/#run"
		exit 1
	fi
}
