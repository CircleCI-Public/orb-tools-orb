#!/bin/bash
# NOTE: an explicit API token is required for orb validation, for self-hosted CircleCI.
# In the case of CircleCI cloud (https://circleci.com), an API token is not needed.
if [ "https://circleci.com" != "${CIRCLECI_API_HOST}" ] && [ -z "${CIRCLE_TOKEN}" ]; then
    echo "Please set a valid CIRCLE_TOKEN token from your self-hosted CircleCI."
    exit 1
fi

if [ -n "${CIRCLE_TOKEN}" ]; then
  set -- "$@" --token "${CIRCLE_TOKEN}"
fi
if [ -n "${CIRCLECI_ORG_SLUG}" ]; then
  set -- "$@" --org-slug "${CIRCLECI_ORG_SLUG}"
fi

circleci orb validate --host "${CIRCLECI_API_HOST:-https://circleci.com}" \
                      --skip-update-check \
                      "$@" \
                      "${ORB_PARAM_OUTPUT_DIR}orb.yml"
