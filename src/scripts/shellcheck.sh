if ! command -v shellcheck &> /dev/null
then
    if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
    $SUDO apt-get update
    $SUDO apt-get install shellcheck
fi

# EXCLUSIONS
# SC2148 - Missing shebang, this is to be expected.
# SC2154 - https://github.com/koalaman/shellcheck/wiki/SC2154 Expects bash env vars to be set. Ignoring will allow you to reference env vars from outside the script

EXCLUDED_SHELL_ERRORS="SC2148,SC2154${EXLUDED_ERRORS}"

shopt -s nullglob dotglob
shellcheck "$SOURCE_DIR"/**.{sh,bash,ksh} --exclude "$EXCLUDED_SHELL_ERRORS"
