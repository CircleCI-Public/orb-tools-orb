#!/bin/bash
PUBLISH_PRODUCTION_ORB=false
ORB_RELEASE_VERSION=""
ORB_PARAM_ORB_PUB_TOKEN=${!ORB_PARAM_ORB_PUB_TOKEN}
mkdir -p /tmp/orb_dev_kit/

function validateProdTag() {
  if [[ ! "${CIRCLE_TAG}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Malformed tag detected."
    echo "Tag: $CIRCLE_TAG"
    echo
    echo "Ensure your tag fits the standard semantic version form. Example: v1.0.0"
    echo "Aborting deployment. Push a new tag with the compatible form."
    exit 1
  fi
}

function validateOrbPubToken() {
  if [[ -z "${ORB_PARAM_ORB_PUB_TOKEN}" ]]; then
    echo "No Orb Publishing Token detected."
    echo "Please set the ORB_PARAM_ORB_PUB_TOKEN environment variable."
    echo "Aborting deployment."
    exit 1
  fi
}

function publishOrb() {
  #$1 = full tag
  circleci orb publish --skip-update-check "${ORB_PARAM_ORB_DIR}/orb.yml" "${ORB_PARAM_ORB_NAME}@${1}" --token "$ORB_PARAM_ORB_PUB_TOKEN"
  printf "\n"
  {
    echo "Your orb has been published to the CircleCI Orb Registry."
    echo "You can view your published orb on the CircleCI Orb Registry at the following link: "
    echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=${1}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}

function publishDevOrbs() {
  publishOrb "dev:${CIRCLE_SHA1}"
  publishOrb "dev:alpha"
  {
    echo "Your development orb has been published. It will expire in 30 days."
    echo "You can preview what this will look like on the CircleCI Orb Registry at the following link: "
    echo "https://circleci.com/developer/orbs/orb/${ORB_PARAM_ORB_NAME}?version=dev:${CIRCLE_SHA1}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}

# The main function
function orbPublish() {
  echo "Preparing to publish your orb."
  validateOrbPubToken
  if [ -n "${CIRCLE_TAG}" ]; then
    PUBLISH_PRODUCTION_ORB=true
    echo "Production release detected!"
    validateProdTag
    ORB_RELEASE_VERSION="${CIRCLE_TAG//v/}"
    echo "Production version: ${ORB_RELEASE_VERSION}"
  fi
  printf "\n"
  if [ "${PUBLISH_PRODUCTION_ORB}" = true ]; then
    publishOrb "${ORB_RELEASE_VERSION}"
  else
    publishDevOrbs
  fi
  # print out the orb publishing message
  printf "\n\n"
  echo "********************************************************************************"
  cat /tmp/orb_dev_kit/publishing_message.txt
}

orbPublish