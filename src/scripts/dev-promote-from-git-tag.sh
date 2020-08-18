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
}

PublishTag() {
    echo $RELEASE_TYPE
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

if [[ "$_" == "$0" ]]; then
    Main
fi