#!/bin/bash
if [[ ! "$CIRCLE_TAG" =~ ^v[0-9]*\.[0-9]*\.[0-9]*$ ]]; then
  echo "Malformed tag detected."
  echo "Tag: $CIRCLE_TAG"
  echo
  echo "Ensure your tag fits the standard semantic version form. Example: v1.0.0"
  echo "Aborting deployment. Push a new tag with the compatible form."
  exit 1
fi

ORB_RELEASE_VERSION="${CIRCLE_TAG//v/}"
echo "Preparing to publish version ${ORB_RELEASE_VERSION} of the ${ORB_PARAM_ORB_NAME} orb."
ORB_PARAM_ORB_PUB_TOKEN=${!ORB_PARAM_ORB_PUB_TOKEN}

circleci orb publish --skip-update-check "${ORB_PARAM_ORB_DIR}/orb.yml" "${ORB_PARAM_ORB_NAME}@${ORB_RELEASE_VERSION}" --token "$ORB_PARAM_ORB_PUB_TOKEN"
echo "Orb prod publishing complete!"
echo "You can view your published orb on the CircleCI Orb Registry at the following link: "
echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=${ORB_RELEASE_VERSION}"

# Set PR message text
mkdir -p /tmp/orb_dev_kit/
{
  echo "Your orb has been published to the CircleCI Orb Registry."
  echo "You can view your published orb on the CircleCI Orb Registry at the following link: "
  echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=${ORB_RELEASE_VERSION}"
} >> /tmp/orb_dev_kit/publishing_message.txt