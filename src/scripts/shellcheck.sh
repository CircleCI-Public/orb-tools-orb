set +e
# Set colors for terminal output
term_red=$'\e[1;31m'
term_green=$'\e[1;32m'
term_end=$'\e[0m'

ORB_SOURCE_FILES=$(find "${SOURCE_DIR}" -type f -name "*.yml" -o -name "*.yaml")
SCRIPT_FILES=$(find "${SOURCE_DIR}" -type f -name "*.sh")

SC_ERROR_COUNT=0

# EXCLUSIONS
# SC2148 - Missing shebang, this is to be expected.
# SC1044 - "\<<" parameter notation before the text replacement will appear like a here document with no EOF. Ignore this error for now.
# SC1072 - Not entirely sure on this one: https://github.com/koalaman/shellcheck/wiki/SC1072. Temporarily adding.
# SC1090 - https://github.com/koalaman/shellcheck/wiki/SC1090
# SC2154 - https://github.com/koalaman/shellcheck/wiki/SC2154 Expects bash env vars to be set. Ignoring will allow you to reference env vars from outside the script

EXCLUDED_SHELL_ERRORS="SC2148,SC1044,SC1072,SC1090,SC2154${EXLUDED_ERRORS}"

###
# For each file
###
function scan_yaml {
    for file in $ORB_SOURCE_FILES
    do
        # Get the number of steps
        echo -----
        echo "Scanning $file"
        ORB_STEP_COUNT=$(yq r "$file" --length steps)
        i=0
        while [[ $i -lt $ORB_STEP_COUNT ]]
        ###
        # For each step in that file
        ###
        do
        # flag to determine if the command should be sent to shellcheck
        SCRIPT_TO_SHELLCHECK=""

        if [[ $(yq r "$file" steps[$i].run) ]]; then
            # if the step is a run step ->
            if [[ ! $(yq r "$file" steps[$i].run.*) ]]; then
            # if the run step has no other sub-keys ->
            SCRIPT_TO_SHELLCHECK=$(yq r "$file" steps[$i].run)
            elif [[ ! $(yq r "$file" steps[$i].run.shell) ]]; then
            # If there is no shell key. ->
            if [[ $(yq r "$file" steps[$i].run.command) ]]; then
                # if there is a command key ->
                SCRIPT_TO_SHELLCHECK=$(yq r "$file" steps[$i].run.command)
            else
                echo "This run statement appears to be missing the command key"
            fi
            fi
        fi

        if [[ -n "$SCRIPT_TO_SHELLCHECK" ]]; then
            echo "$SCRIPT_TO_SHELLCHECK" | shellcheck --exclude $EXCLUDED_SHELL_ERRORS -
            if [[ $? == 1 ]]; then
            # When an error is discovered
            printf "${term_red}Error discovered in $file at step $((i+1))${term_end}\n"
            echo ---
            echo
            ((SC_ERROR_COUNT++))
            fi
        else
            echo ---
            echo
            echo $(yq r "$file" steps[$i])
            echo
            echo Unable to shellcheck this command. Skipping.
            echo
            echo ---
            echo
        fi
        ((i++))
        done
        echo
    done
}

function scan_scripts {
    for file in $SCRIPT_FILES
    do
        SCRIPT_TO_SHELLCHECK=$(cat "$file")

        if [[ -n "$SCRIPT_TO_SHELLCHECK" ]]; then
            echo "$SCRIPT_TO_SHELLCHECK" | shellcheck --exclude $EXCLUDED_SHELL_ERRORS -
            if [[ $? == 1 ]]; then
                # When an error is discovered
                printf "${term_red}Error discovered in $file${term_end}\n"
                echo ---
                echo
                ((SC_ERROR_COUNT++))
            fi
        fi
    done
}

scan_yaml
scan_scripts

set -e
if [ "$SC_ERROR_COUNT" -gt 0 ]; then
    echo -------------------------------------
    printf "${term_red}Shellcheck has discovered errors. Please view and correct the errors shown above.${term_end}\n"
    printf "${term_red}If desired, error codes may also be added to the exclusion list via the exclude parameter${term_end}\n"
    echo -------------------------------------
    exit 1
else
    echo -------------------------------------
    printf "${term_green}Shellcheck passed.${term_end}\n"
    echo -------------------------------------
    exit 0
fi
