#!/bin/bash
# NOTE: an explicit API token is required for orb validation, for self-hosted CircleCI.
# In the case of CircleCI cloud (https://circleci.com), an API token is not needed.
if [ "https://circleci.com" != "${CIRCLECI_API_HOST}" ] && [ -z "${CIRCLE_TOKEN}" ]; then
    echo "Please set a valid CIRCLE_TOKEN token from your self-hosted CircleCI."
    exit 1
fi

circleci orb validate --host "${CIRCLECI_API_HOST:-https://circleci.com}" --token "${CIRCLE_TOKEN:-dummy}" --skip-update-check "${ORB_PARAM_OUTPUT_DIR}/${ORB_PARAM_OUTPUT_FILENAME}"
