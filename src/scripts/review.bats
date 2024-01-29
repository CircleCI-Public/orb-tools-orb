setup() {
	ORB_DEFAULT_SRC_DIR="./src/"
	ORB_SOURCE_DIR=${ORB_VAL_SOURCE_DIR:-$ORB_DEFAULT_SRC_DIR}
	ORB_SOURCE_DIR=${ORB_SOURCE_DIR%/}
	IFS="," read -ra SKIPPED_REVIEW_CHECKS <<<"${ORB_VAL_RC_EXCLUDE}"
}

@test "RC001: Include source_url in @orb.yml" {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC001" ]]; then
		skip
	fi
	result=$(yq '.display.source_url' "${ORB_SOURCE_DIR}/@orb.yml")

	echo 'Set a value for "source_url" under the "display" key in "@orb.yml"'
	[[ ! $result = null ]]
}

@test "RC002: All components (jobs, commands, executors, examples) must have descriptions" {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC002" ]]; then
		skip
	fi
	for i in $(find "${ORB_SOURCE_DIR}/jobs" "${ORB_SOURCE_DIR}/examples" "${ORB_SOURCE_DIR}/commands" "${ORB_SOURCE_DIR}/executors" -name "*.yml" 2>/dev/null); do
		ORB_ELEMENT_DESCRIPTION=$(yq '.description' "$i")
		if [[ "$ORB_ELEMENT_DESCRIPTION" == null || "$ORB_ELEMENT_DESCRIPTION" == '""' ]]; then
			echo
			echo "Orb component ${i} is missing a description"
			echo "While descriptions are not required to create a valid orb, they provide a way to document the purpose of each component and will appear in the orb registry."
			echo "Check all orb components for descriptions."
			exit 1
		fi
	done
}

@test "RC003: All production-ready orbs should contain at least one usage example." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC003" ]]; then
		skip
	fi
	ORB_ELEMENT_EXAMPLE_COUNT=$(find ${ORB_SOURCE_DIR}/examples/*.yml -type f 2>/dev/null | wc -l | xargs)
	if [ "$ORB_ELEMENT_EXAMPLE_COUNT" -lt 1 ]; then
		echo
		echo "This orb appears to be missing a usage example."
		echo "Add examples under $(${ORB_SOURCE_DIR}/examples) to document how to use the orb for any available use cases."
		exit 1
	fi
}

@test "RC004: Usage example names shoud be descriptive." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC004" ]]; then
		skip
	fi
	for i in $(find "${ORB_SOURCE_DIR}examples/*.yml" -type f >/dev/null 2>&1); do
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
	ORB_ELEMENT_DESCRIPTION=$(yq '.description' "${ORB_SOURCE_DIR}/@orb.yml")
	if [[ "${#ORB_ELEMENT_DESCRIPTION}" -lt 64 ]]; then
		echo
		echo "Orb description appears short (under 64 characters)."
		echo "Update the description in ${ORB_SOURCE_DIR}/@orb.yml to provide a detailed description of the orb."
		echo "Use the orb description to help users find your orb via search. Try describing what use-case this orb solves for."
		exit 1
	fi
}

@test "RC006: Source URL should be valid." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC006" ]]; then
		skip
	fi
	SOURCE_URL=$(yq '.display.source_url' "${ORB_SOURCE_DIR}/@orb.yml")
	HTTP_RESPONSE=$(curl -s -L -o /dev/null -w "%{http_code}" --retry 5 --retry-delay 5 "$SOURCE_URL")
	if [[ "$HTTP_RESPONSE" -ne 200 ]]; then
		echo
		echo "Source URL: \"$SOURCE_URL\" is not reachable."
		echo "Check the Source URL for this orb."
		exit 1
	fi
}

@test "RC007: Home URL should be valid." {
	HOME_URL=$(yq '.display.home_url' "${ORB_SOURCE_DIR}/@orb.yml")
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
	for i in $(find "${ORB_SOURCE_DIR}/jobs" "${ORB_SOURCE_DIR}/commands" -name "*.yml" 2>/dev/null); do
		ORB_COMPONENT_STEPS_COUNT=$(yq '[.steps.[] | .run | select(. != null)] | length' "$i")
		j=0
		while [ "$j" -lt "$ORB_COMPONENT_STEPS_COUNT" ]; do
			ORB_COMPONENT_STEP=$(yq "[.steps.[] | .run | select(. != null)][$j]" "$i")
			ORB_COMPONENT_STEP_TYPE=$(echo "$ORB_COMPONENT_STEP" | yq -o=json '.' | jq 'type')
			ORB_COMPONENT_LINE_NUMBER=$(yq "[.steps.[] | .run | select(. != null)][$j] | line" "$i")
			ORB_COMPONENT_STEP_NAME=$(yq "[.steps.[] | .run | select(. != null)][$j] | .name" "$i")
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
				yq "[.steps.[] | .run | select(. != null)][$j]" "$i"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			fi
			j=$((j + 1))
		done
	done
	if [[ "$ERROR_COUNT" -gt 0 ]]; then
		echo
		echo "Components were found to contain \"run\" steps without a name."
		echo "While a step does not require a name to be valid, not providing a name will produce a less readable output in the CircleCI UI."
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
	for i in $(find ${ORB_SOURCE_DIR}/jobs ${ORB_SOURCE_DIR}/commands -name "*.yml" 2>/dev/null); do
		ORB_COMPONENT_STEPS_COUNT=$(yq '[.steps.[] | .run | select(. != null)] | length' "$i")
		j=0
		while [ "$j" -lt "$ORB_COMPONENT_STEPS_COUNT" ]; do
			ORB_COMPONENT_STEP=$(yq "[.steps.[] | .run | select(. != null)][$j]" "$i")
			ORB_COMPONENT_STEP_TYPE=$(echo "$ORB_COMPONENT_STEP" | yq -o=json '.' | jq 'type')
			ORB_COMPONENT_LINE_NUMBER=$(yq "[.steps.[] | .run | select(. != null)][$j] | line" "$i")
			ORB_COMPONENT_STEP_COMMAND=$(yq "[.steps.[] | .run | select(. != null)][$j] | .command" "$i")
			if [[ "$ORB_COMPONENT_STEP_TYPE" == '"string"' ]]; then
				echo "File: \"${i}\""
				echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
				echo "It appears this 'run' step is using 'string' formatting."
				echo "Consider converting this step into an object with a \"name\" and \"command\" property."
				echo ---
				echo "$ORB_COMPONENT_STEP"
				echo ---
				ERROR_COUNT=$((ERROR_COUNT + 1))
			elif [[ "${#ORB_COMPONENT_STEP_COMMAND}" -gt "${ORB_VAL_MAX_COMMAND_LENGTH}" ]]; then
				if [[ ! "$ORB_COMPONENT_STEP_COMMAND" =~ \<\<include\(* ]]; then
					echo "File: \"${i}\""
					echo "Line number: ${ORB_COMPONENT_LINE_NUMBER}"
					echo "This command appears longer than ${ORB_VAL_MAX_COMMAND_LENGTH} characters. Consider using the 'include' syntax."
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

@test "RC010: All components (jobs, commands, executors, examples) should be snake_cased." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC010" ]]; then
		skip
	fi
	for i in $(find "${ORB_SOURCE_DIR}/jobs" "${ORB_SOURCE_DIR}/commands" "${ORB_SOURCE_DIR}/executors" -name "*.yml" 2>/dev/null); do
		# Check file name for snake_case
		ORB_COMPONENT_FILE_NAME=$(basename "$i")
		if [[ "$ORB_COMPONENT_FILE_NAME" == *"-"* ]]; then
			echo "File: \"${i}\""
			echo "Component names should be snake_cased. Please rename this file to use snake_case."
			exit 1
		fi

		# Check if the file has parameters, if not skip counting.
		HAS_PARAMETERS=$(yq 'has("parameters")' "$i")
		if [[ "$HAS_PARAMETERS" == "false" ]]; then
			continue
		fi

		# Check parameter keys on component for snake_case
		ORB_COMPONENT_PARAMETERS_COUNT=$(yq '.parameters | keys | .[]' "$i")
		for j in $ORB_COMPONENT_PARAMETERS_COUNT; do
			if [[ "$j" == *"-"* ]]; then
				echo "File: \"${i}\""
				echo " Parameter: \"${j}\""
				echo "Parameter keys should be snake_cased. Please rename this parameter to use snake_case."
				exit 1
			fi
		done

	done
}

@test "RC011: Ensure usage examples showcase current major version of the orb." {
	if [[ "${SKIPPED_REVIEW_CHECKS[*]}" =~ "RC011" ]]; then
		skip
	fi

	if [[ -z "$CIRCLE_TAG" ]]; then
		echo "No tag detected. Skipping usage example check."
		skip
	fi

	if [[ ! "$CIRCLE_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		echo "Non-production tag detected. Skipping usage example check."
		skip
	fi

	CURRENT_MAJOR_VERSION=$(echo "${CIRCLE_TAG#v}" | cut -d '.' -f 1)

	for i in $(find "${ORB_SOURCE_DIR}/examples" -name "*.yml" -type f); do
		ORB_REF_STRING=$(yq ".usage.orbs[\"${ORB_VAL_ORB_NAME}\"]" "$i")
		ORB_REF_VERSION_STRING=$(echo "$ORB_REF_STRING" | cut -d '@' -f 2)
		ORB_REF_MAJOR_VERSION=$(echo "$ORB_REF_VERSION_STRING" | cut -d '.' -f 1)

		if [[ "$ORB_REF_MAJOR_VERSION" != "$CURRENT_MAJOR_VERSION" ]]; then
			echo "File: \"${i}\""
			echo "Orb version: \"${ORB_REF_VERSION_STRING}\""
			echo "Current major version: \"${CURRENT_MAJOR_VERSION}\""
			echo "Usage examples should showcase at least the current major version of the orb."
			echo ""
			echo "Steps to resolve:"
			echo "  1. Delete the tag from your git repository which triggered this pipeline."
			echo "  2. Update all of the orb usage examples to ensure they match the next major version of the orb."
			echo "  3. Re-tag and release the orb to re-trigger the pipeline"

			exit 1
		fi
	done
}
