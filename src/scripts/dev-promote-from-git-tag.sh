RELEASE_TYPE=''
MAJOR_RELEASE_TAG_REGEX="<<parameters.major-release-tag-regex>>"
MINOR_RELEASE_TAG_REGEX="<<parameters.minor-release-tag-regex>>"
PATCH_RELEASE_TAG_REGEX="<<parameters.patch-release-tag-regex>>"
if [[ "${CIRCLE_TAG}" =~ ${MAJOR_RELEASE_TAG_REGEX} ]]; then
    RELEASE_TYPE='major'
elif [[ "${CIRCLE_TAG}" =~ ${MINOR_RELEASE_TAG_REGEX} ]]; then
    RELEASE_TYPE='minor'
elif [[ "${CIRCLE_TAG}" =~ ${PATCH_RELEASE_TAG_REGEX} ]]; then
    RELEASE_TYPE='patch'
fi
if [ -n "${RELEASE_TYPE}" ]; then
    PUBLISH_MESSAGE=`circleci orb publish promote \
    <<parameters.orb-name>>@<<parameters.orb-ref>> \
    ${RELEASE_TYPE} --token \
    ${<<parameters.token-variable>>} \
    --skip-update-check`
    echo $PUBLISH_MESSAGE
    ORB_VERSION=$(echo $PUBLISH_MESSAGE | sed -n 's/Orb .* was promoted to `\(.*\)`.*/\1/p')
    echo "export PR_MESSAGE=\"BotComment: *Production* version of orb available for use - \\\`${ORB_VERSION}\\\`\"" >> $BASH_ENV
fi