echo "Indicated semver increment was: ${SEMVER_INCREMENT}"
echo "Version of orb published: ${ORB_VERSION}"
if [ -z "${ORB_VERSION}" ] || [ -z "${SEMVER_INCREMENT}" ] || [ "${SEMVER_INCREMENT}" == "skip" ]; then
    echo "Release tags will not be published."
    echo "Reason: \"skip\" or no semver increment was indicated, or the orb was not published."
    circleci step halt
fi