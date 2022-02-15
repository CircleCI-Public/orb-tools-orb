#!/bin/bash
if [[ ! "$CIRCLE_TAG" =~ ^v[0-9]*\.[0-9]*\.[0-9]*$ ]]; then {
  echo "Malformed tag detected."
  echo "Tag: $CIRCLE_TAG"
  echo
  echo "Ensure your tag fits the standard semantic version form. Example: v1.0.0"
  echo
  echo "Aborting deployment. Push a new tag with the compatible form."
  exit 1
}

ORB_RELEASE_VERSION=$(echo "$CIRCLE_TAG" | sed s/v//)
echo "Preparing to publish version ${ORB_RELEASE_VERSION} of the ${ORB_PARAM_ORB_NAME} orb."
ORB_PARAM_ORB_PUB_TOKEN=${!ORB_PARAM_ORB_PUB_TOKEN}

circleci orb publish --skip-update-check "${ORB_PARAM_ORB_DIR}/orb.yml" "${ORB_PARAM_ORB_NAME}@${ORB_RELEASE_VERSION}" --token "$ORB_PARAM_ORB_PUB_TOKEN"

echo "Orb prod publishing complete!"
echo "You can view your published orb on the CircleCI Orb Registry at the following link: "
echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=${ORB_RELEASE_VERSION"