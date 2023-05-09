#!/bin/bash

ORB_DIR=${ORB_PARAM_ORB_DIR%/}
ORB_FILE=${ORB_PARAM_ORB_FILE_NAME#/}

function validateProdTag() {
  if [[ ! "${CIRCLE_TAG}" =~ $ORB_PARAM_TAG_PATTERN ]]; then
    printf "Malformed tag detected.\n"
    printf "Tag: %s\n\n" "$CIRCLE_TAG"
    printf "A production release has attempted to occur, but the tag does not match the expected pattern.\n"
    printf "Aborting deployment. Push a new tag with the compatible form.\n"
    printf "Current tag pattern: %s\n" "$ORB_PARAM_TAG_PATTERN"
    exit 1
  fi
}

function validateOrbPubToken() {
  if [[ -z "${ORB_PARAM_ORB_PUB_TOKEN}" ]]; then
    printf "No Orb Publishing Token detected.\n"
    printf "Please set the CIRCLE_TOKEN environment variable.\n"
    printf "Aborting deployment.\n"
    exit 1
  fi
}

function publishOrb() {
  #$1 = full tag

  circleci orb publish --host "${CIRCLECI_API_HOST:-https://circleci.com}" --skip-update-check "${ORB_DIR}/${ORB_FILE}" "${ORB_PARAM_ORB_NAME}@${1}" --token "$ORB_PARAM_ORB_PUB_TOKEN"
  printf "\n"
  {
    printf "Your orb has been published to the CircleCI Orb Registry.\n"
    printf "You can view your published orb on the CircleCI Orb Registry at the following link: \n"
    printf "https://circleci.com/developer/orbs/orb/%s?version=%s\n" "${ORB_PARAM_ORB_NAME}" "${1}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}

function publishDevOrbs() {
  printf "Publishing development orb(s).\n\n"
  DEV_TAG_LIST=$(echo "${ORB_PARAM_DEV_TAGS}" | tr -d ' ')
  IFS=',' read -ra array <<<"$DEV_TAG_LIST"
  for tag in "${array[@]}"; do
    publishOrb "$tag"
  done
  {
    printf "Your development orb(s) have been published. It will expire in 30 days.\n"
    printf "You can preview what this will look like on the CircleCI Orb Registry at the following link: \n"
    printf "https://circleci.com/developer/orbs/orb/%s?version=dev:%s\n" "${ORB_VAL_ORB_NAME}" "${array[0]}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}

# The main function
function orbPublish() {
  printf "Preparing to publish your orb.\n"
  validateOrbPubToken

  if [ "$ORB_PARAM_PUB_TYPE" == "production" ]; then
    printf "Production release detected!\n"
    if [ -z "$CIRCLE_TAG" ]; then
      printf "No tag detected. Exiting.\n"
      printf "If you are trying to publish a production orb, you must push a semantically versioned tag.\n"
      exit 1
    fi
    validateProdTag
    ORB_RELEASE_VERSION="$(echo "${CIRCLE_TAG}" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+")"
    printf "  Production version: %s\n\n" "${ORB_RELEASE_VERSION}"
    publishOrb "${ORB_RELEASE_VERSION}"
  elif [ "$ORB_PARAM_PUB_TYPE" == "dev" ]; then
    printf "  Development release detected!\n\n"
    publishDevOrbs
  else
    printf "  No release type detected.\n"
    printf "  Please report this error.\n"
  fi

  printf "\n\n"
  printf "********************************************************************************\n"
  cat /tmp/orb_dev_kit/publishing_message.txt

}

ORB_RELEASE_VERSION=""
ORB_PARAM_ORB_PUB_TOKEN=${!ORB_PARAM_ORB_PUB_TOKEN}
mkdir -p /tmp/orb_dev_kit/
orbPublish