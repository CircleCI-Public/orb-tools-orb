Setup() {
    COMMIT_SUBJECT=$(git log -1 --pretty=%s.)
    T=$(eval echo "$TOKEN")
    REF=$(eval echo "$ORB_REF")
}

GetIncrement() {
    SEMVER_INCREMENT=$(echo "${COMMIT_SUBJECT}" | sed -En 's/.*\[semver:(major|minor|patch|skip)\].*/\1/p')
    echo "Commit subject: ${COMMIT_SUBJECT}"
    echo "export SEMVER_INCREMENT=\"$SEMVER_INCREMENT\""  >> "$BASH_ENV"
}

PublishOrb() {
    PUBLISH_MESSAGE=$(circleci orb publish promote "${ORB_NAME}@${REF}" "${SEMVER_INCREMENT}" --token "$T" --skip-update-check)
    echo "$PUBLISH_MESSAGE"
    ORB_VERSION=$(echo "$PUBLISH_MESSAGE" | sed -n 's/Orb .* was promoted to `\(.*\)`.*/\1/p')
    echo "export ORB_VERSION=\"$ORB_VERSION\"" >> "$BASH_ENV"
}

CheckIncrement() {
    if [ -z "${SEMVER_INCREMENT}" ];then
        echo "Commit subject did not indicate which SemVer increment to make."
        echo "To publish orb, you can ammend the commit or push another commit with [semver:FOO] in the subject where FOO is major, minor, patch."
        echo "Note: To indicate intention to skip promotion, include [semver:skip] in the commit subject instead."
        if [ "$SHOULD_FAIL" == "1" ];then
            exit 1
        else
        echo "export PR_MESSAGE=\"BotComment: Orb publish was skipped due to [semver:patch|minor|major] not being included in commit message.\""  >> "$BASH_ENV"
        fi
    elif [ "$SEMVER_INCREMENT" == "skip" ];then
        echo "SEMVER in commit indicated to skip orb release"
        echo "export PR_MESSAGE=\"BotComment: Orb publish was skipped due to [semver:skip] in commit message.\""  >> "$BASH_ENV"
    else
        PublishOrb
        echo "export PR_MESSAGE=\"BotComment: *Production* version of orb available for use - \\\`${ORB_VERSION}\\\`\"" >> "$BASH_ENV"
    fi
}

Main() {
    Setup
    GetIncrement
    CheckIncrement
}

# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
fi