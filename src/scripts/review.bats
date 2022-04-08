setup() {
	REVIEW_TEST_DIR="./"
	IFS="," read -ra SKIPPED_REVIEW_CHECKS <<<"${PARAM_RC_EXCLUDE}"
}

@test "RC001: Include source_url in @orb.yml" {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC001" ]]; then
		skip
	fi
	result=$(yq '.display.source_url' "${REVIEW_TEST_DIR}src/@orb.yml")

	echo 'Set a value for "source_url" under the "display" key in "@orb.yml"'
	[[ ! $result = null ]]
}

@test "RC002: All components (jobs, commands, executors, examples) must have descriptions" {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC002" ]]; then
		skip
	fi
	for i in $(find "${REVIEW_TEST_DIR}src/jobs" "${REVIEW_TEST_DIR}src/examples" "${REVIEW_TEST_DIR}src/commands" "${REVIEW_TEST_DIR}src/executors" -name "*.yml" 2>/dev/null); do
		ORB_ELEMENT_DESCRIPTION=$(yq '.description' "$i")
		if [[ "$ORB_ELEMENT_DESCRIPTION" == null || "$ORB_ELEMENT_DESCRIPTION" == '""' ]]; then
			echo
			echo "Orb component ${i} is missing a description"
			echo "Orb components are not invalid without descriptions, but these descriptions appear on the Orb Registry for documentation and provide a better experience."
			echo "Check all orb components for descriptions."
			exit 1
		fi
	done
}

@test "RC003: All production-ready orbs should contain at least one usage example." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC003" ]]; then
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
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC004" ]]; then
		skip
	fi
	for i in $(find "${REVIEW_TEST_DIR}/src/examples/*.yml" -type f >/dev/null 2>&1); do
		if [[ $i =~ "example" ]]; then
			echo
			echo "Usage example file name ${i} contains the word 'example'."
			echo "Usage example file names should be descriptive and not contain the word 'example'."
			exit 1
		fi
	done
}

@test "RC005: Write a detailed orb description." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC005" ]]; then
		skip
	fi
	ORB_ELEMENT_DESCRIPTION=$(yq '.description' "${REVIEW_TEST_DIR}src/@orb.yml")
	if [[ "${#ORB_ELEMENT_DESCRIPTION}" -lt 64 ]]; then
		echo
		echo "Orb description appears short (under 64 characters)."
		echo "Update the description in ${REVIEW_TEST_DIR}src/@orb.yml to provide a detailed description of the orb."
		echo "Use the orb description to help users find your orb via search. Try describing what use-case this orb solves for."
		exit 1
	fi
}

@test "RC006: Source URL should be valid." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC006" ]]; then
		skip
	fi
	SOURCE_URL=$(yq '.display.source_url' "${REVIEW_TEST_DIR}/src/@orb.yml")
	HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 "$SOURCE_URL")
	if [[ "$HTTP_RESPONSE" -ne 200 ]]; then
		echo
		echo "Source URL: \"$SOURCE_URL\" is not reachable."
		echo "Check the Source URL for this orb."
		exit 1
	fi
}

@test "RC007: Home URL should be valid." {
	HOME_URL=$(yq '.display.home_url' "${REVIEW_TEST_DIR}/src/@orb.yml")
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC007" || "$HOME_URL" == "null" ]]; then
		skip
	fi
	HTTP_RESPONSE=$(curl -s -L -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 "$HOME_URL")
	if [[ "$HTTP_RESPONSE" -ne 200 ]]; then
		echo
		echo "Home URL: \"$HOME_URL\" is not reachable."
		echo "Check the Home URL for this orb."
		exit 1
	fi
}

@test "RC008: All Run steps should contain a name." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC008" ]]; then
		skip
	fi
	ERROR_COUNT=0
	for i in $(find "${REVIEW_TEST_DIR}src/jobs" "${REVIEW_TEST_DIR}src/commands" -name "*.yml" 2>/dev/null); do
		ORB_COMPONENT_STEPS_COUNT=$(yq '[.steps.[] | .run] | length' "$i")
		j=0
		while [ "$j" -lt "$ORB_COMPONENT_STEPS_COUNT" ]; do
			ORB_COMPONENT_STEP=$(yq "[.steps.[] | .run][$j]" "$i")
			ORB_COMPONENT_STEP_TYPE=$(echo "$ORB_COMPONENT_STEP" | yq -o=json '.' | jq 'type')
			ORB_COMPONENT_LINE_NUMBER=$(yq "[.steps.[] | .run][$j] | line" "$i")
			ORB_COMPONENT_STEP_NAME=$(yq "[.steps.[] | .run][$j] | .name" "$i")
			if [[ "$ORB_COMPONENT_STEP_TYPE" == '"string"' ]]; then
				echo "File: \"${i}\""
				echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
				echo "It appears this 'run' step is using 'string' formatting."
				echo "Consider converting this step into an object with a \"name\" and \"command\" property."
				echo ---
				echo "$ORB_COMPONENT_STEP"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			elif [[ "$ORB_COMPONENT_STEP_NAME" == null || "$ORB_COMPONENT_STEP_NAME" == '""' ]]; then
				echo "File: \"${i}\""
				echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
				echo ---
				yq "[.steps.[] | .run][$j]" "$i"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			fi
			j=$((j + 1))
		done
	done
	if [[ "$ERROR_COUNT" -gt 0 ]]; then
		echo
		echo "Components were found to contain \"run\" steps without a name."
		echo "Steps are not invalid without names, but the default used will be the command code, which can be long and confusing."
		echo "Consider adding a name to the step to make the output in the UI easier to read."
		echo "https://circleci.com/docs/2.0/configuration-reference/#run"
		exit 1
	fi
}

@test "RC009: Complex Run step's commands should be imported." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC009" ]]; then
		skip
	fi
	ERROR_COUNT=0
	for i in $(find ${REVIEW_TEST_DIR}src/jobs ${REVIEW_TEST_DIR}src/commands -name "*.yml" 2>/dev/null); do
		ORB_COMPONENT_STEPS_COUNT=$(yq '[.steps.[] | .run] | length' "$i")
		j=0
		while [ "$j" -lt "$ORB_COMPONENT_STEPS_COUNT" ]; do
			ORB_COMPONENT_STEP=$(yq "[.steps.[] | .run][$j]" "$i")
			ORB_COMPONENT_STEP_TYPE=$(echo "$ORB_COMPONENT_STEP" | yq -o=json '.' | jq 'type')
			ORB_COMPONENT_LINE_NUMBER=$(yq "[.steps.[] | .run][$j] | line" "$i")
			ORB_COMPONENT_STEP_COMMAND=$(yq "[.steps.[] | .run][$j] | .command" "$i")
			if [[ "$ORB_COMPONENT_STEP_TYPE" == '"string"' ]]; then
				echo "File: \"${i}\""
				echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
				echo "It appears this 'run' step is using 'string' formatting."
				echo "Consider converting this step into an object with a \"name\" and \"command\" property."
				echo ---
				echo "$ORB_COMPONENT_STEP"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			elif [[ "${#ORB_COMPONENT_STEP_COMMAND}" -gt 64 ]]; then
				if [[ ! "$ORB_COMPONENT_STEP_COMMAND" =~ \<\<include\(* ]]; then
					echo "File: \"${i}\""
					echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
					echo "This command appears longer than 64 characters. Consider using the 'include' syntax."
					echo ---
					echo "$ORB_COMPONENT_STEP_COMMAND"
					echo ---
					ERROR_COUNT=$((ERROR_COUNT + 1))
				fi
			fi
			j=$((j + 1))
		done
	done
	if [[ "$ERROR_COUNT" -gt 0 ]]; then
		echo
		echo "Components were found to contain \"run\" steps with a long command that is not imported."
		echo "Did you know you can write your shell scripts and other commands in external files and import them here?"
		echo "Writing your scripts externally will allow you to take advantage of syntax highlighting and avoid mixing code and markup."
		echo "https://circleci.com/docs/2.0/using-orbs/#file-include-syntax"
		exit 1
	fi
}
