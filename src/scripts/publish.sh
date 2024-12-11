#!/bin/bash

ORB_DIR=${ORB_VAL_ORB_DIR%/}
ORB_FILE=${ORB_VAL_ORB_FILE_NAME#/}

function validateProdTag() {
  if [[ ! "${CIRCLE_TAG}" =~ $ORB_VAL_TAG_PATTERN ]]; then
    printf "Malformed tag detected.\n"
    printf "Tag: %s\n\n" "$CIRCLE_TAG"
    printf "A production release has attempted to occur, but the tag does not match the expected pattern.\n"
    printf "Aborting deployment. Push a new tag with the compatible form.\n"
    printf "Current tag pattern: %s\n" "$ORB_VAL_TAG_PATTERN"
    exit 1
  fi
}

function validateOrbPubToken() {
  if [[ -z "${ORB_VAL_ORB_PUB_TOKEN}" ]]; then
    printf "No Orb Publishing Token detected.\n"
    printf "Please set the CIRCLE_TOKEN environment variable.\n"
    printf "Aborting deployment.\n"
    exit 1
  fi
}

function publishOrb() {
  #$1 = full tag

  circleci orb publish --host "${ORB_VAL_CIRCLECI_API_HOST:-https://circleci.com}" --skip-update-check "${ORB_DIR}/${ORB_FILE}" "${ORB_VAL_ORB_NAME}@${1}" --token "$ORB_VAL_ORB_PUB_TOKEN"

  # Track release if ORB_VAL_RELEASE_ENVIRONMENT is set
  if [[ -n "${ORB_VAL_RELEASE_ENVIRONMENT}" ]]; then
    circleci-agent run release log --environment-name="${ORB_VAL_RELEASE_ENVIRONMENT}" --component-name="${ORB_VAL_ORB_NAME}" --target-version="${1}"
  fi
  
  printf "\n"
  {
    printf "Your orb has been published to the CircleCI Orb Registry.\n"
    printf "You can view your published orb on the CircleCI Orb Registry at the following link: \n"
    printf "https://circleci.com/developer/orbs/orb/%s?version=%s\n" "${ORB_VAL_ORB_NAME}" "${1}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}

function publishDevOrbs() {
  printf "Publishing development orb(s).\n\n"
  ORB_REG_LINKS=()
  DEV_TAG_LIST=$(echo "${ORB_VAL_DEV_TAGS}" | tr -d ' ')
  IFS=',' read -ra array <<<"$DEV_TAG_LIST"
  for tag in "${array[@]}"; do
    # shellcheck disable=SC2005
    PROCESSED_TAG=$(circleci env subst "$tag")
    ORB_REG_LINKS+=("$(printf 'https://circleci.com/developer/orbs/orb/%s?version=%s' "$ORB_VAL_ORB_NAME" "$PROCESSED_TAG")")
    publishOrb "$PROCESSED_TAG"
  done
  {
    printf "Your development orb(s) have been published. It will expire in 90 days.\n"
    printf "You can preview what this will look like on the CircleCI Orb Registry at the following link(s): \n"
    printf "%s\n" "${ORB_REG_LINKS[@]}"
  } >/tmp/orb_dev_kit/publishing_message.txt
}


# The main function
function orbPublish() {
  printf "Preparing to publish your orb.\n"
  validateOrbPubToken

  if [ "$ORB_VAL_PUB_TYPE" == "production" ]; then
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
  elif [ "$ORB_VAL_PUB_TYPE" == "dev" ]; then
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
ORB_VAL_ORB_PUB_TOKEN=${!ORB_VAL_ORB_PUB_TOKEN}
mkdir -p /tmp/orb_dev_kit/
orbPublish
