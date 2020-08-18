Setup() {
    RELEASE_TYPE=''
    T=$(eval echo "$TOKEN")
    REF=$(eval echo "$ORB_REF")
}

DiscoverTag() {
    if [[ "${CIRCLE_TAG}" =~ ${MAJOR_RELEASE_TAG_REGEX} ]]; then
        RELEASE_TYPE='major'
    elif [[ "${CIRCLE_TAG}" =~ ${MINOR_RELEASE_TAG_REGEX} ]]; then
        RELEASE_TYPE='minor'
    elif [[ "${CIRCLE_TAG}" =~ ${PATCH_RELEASE_TAG_REGEX} ]]; then
        RELEASE_TYPE='patch'
    fi
    echo "export RELEASE_TYPE=\"$RELEASE_TYPE\"" >> $BASH_ENV
}

PublishTag() {
    if [ -n "${RELEASE_TYPE}" ]; then
        PUBLISH_MESSAGE=$(circleci orb publish promote \
        "${ORB_NAME}@${REF}" \
        "${RELEASE_TYPE}" --token \
        "${T}" \
        --skip-update-check)
        echo "$PUBLISH_MESSAGE"
        ORB_VERSION=$(echo "$PUBLISH_MESSAGE" | sed -n 's/Orb .* was promoted to `\(.*\)`.*/\1/p')
        echo "export PR_MESSAGE=\"BotComment: *Production* version of orb available for use - \\\`${ORB_VERSION}\\\`\"" >> "$BASH_ENV"
    else
        echo "Unable to determine semver bump from tag (${CIRCLE_TAG})."
    fi
}

Main() {
    Setup
    DiscoverTag
    PublishTag
}

# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
fi