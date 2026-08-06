#!/bin/bash
# NOTE: an explicit API token is required for orb validation, for self-hosted CircleCI.
# In the case of CircleCI cloud (https://circleci.com), an API token is not needed.

ORB_DIR=${ORB_VAL_ORB_DIR%/}
ORB_FILE=${ORB_VAL_ORB_FILE_NAME#/}


if [ "https://circleci.com" != "${ORB_VAL_CIRCLECI_API_HOST}" ] && [ -z "${CIRCLE_TOKEN}" ]; then
    echo "Please set a valid CIRCLE_TOKEN token from your self-hosted CircleCI."
    exit 1
fi

# The v1 CircleCI CLI reads the host and token from CIRCLE_HOST/CIRCLE_TOKEN instead of
# --host/--token, and replaced --org-id/--org-slug with a single --org taking either form.
CLI_MAJOR_VERSION=$(circleci version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -n1 | cut -d. -f1)

if [ "${CLI_MAJOR_VERSION:-1}" -ge 1 ]; then
  ORB_VAL_ORG=${ORB_VAL_ORG_ID:-$ORB_VAL_ORG_SLUG}
  CIRCLE_HOST="${ORB_VAL_CIRCLECI_API_HOST:-https://circleci.com}" \
    CIRCLE_TOKEN="${CIRCLE_TOKEN:-dummy}" \
    circleci orb validate ${ORB_VAL_ORG:+--org "$ORB_VAL_ORG"} "${ORB_DIR}/${ORB_FILE}"
else
  circleci orb validate --host "${ORB_VAL_CIRCLECI_API_HOST:-https://circleci.com}" --token "${CIRCLE_TOKEN:-dummy}" ${ORB_VAL_ORG_ID:+--org-id "$ORB_VAL_ORG_ID"} ${ORB_VAL_ORG_SLUG:+--org-slug "$ORB_VAL_ORG_SLUG"} --skip-update-check "${ORB_DIR}/${ORB_FILE}"
fi
