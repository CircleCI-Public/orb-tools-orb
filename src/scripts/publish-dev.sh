#!/bin/bash
# The provided orb source will be published as a dev orb under two different development tags
# dev:alpha | dev:XXXXXXX
# In the latter example, the first 7 characters of the commit SHA will replace the Xs

echo "Preparing to publish development versions of the ${ORB_PARAM_ORB_NAME} orb."
ORB_PARAM_ORB_PUB_TOKEN=${!ORB_PARAM_ORB_PUB_TOKEN}

circleci orb publish --skip-update-check "${ORB_PARAM_ORB_DIR}/orb.yml" "${ORB_PARAM_ORB_NAME}@dev:alpha" --token "$ORB_PARAM_ORB_PUB_TOKEN"
printf "\n"
echo "${ORB_PARAM_ORB_NAME}@dev:alpha has been published"
printf "\n\n\n"
circleci orb publish --skip-update-check "${ORB_PARAM_ORB_DIR}/orb.yml" "${ORB_PARAM_ORB_NAME}@dev:${CIRCLE_SHA1}" --token "$ORB_PARAM_ORB_PUB_TOKEN"
echo "${ORB_PARAM_ORB_NAME}@dev:${CIRCLE_SHA1} has been published"
printf "\n\n\n"
echo "Orb dev publishing complete!"
echo -e "You can \e[3mpreview\e[0m what this would will look like on the CircleCI Orb Registry at the following link: "
echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=dev:${CIRCLE_SHA1}"