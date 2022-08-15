#!/bin/bash
# NOTE: when validating against CircleCI Cloud, no explicit API Token is needed.
# Hence, the --token option here falls back to a dummy value
circleci orb validate --host "${CIRCLECI_API_HOST:-}" --token "${CIRCLE_TOKEN:-dummy}" --skip-update-check "${ORB_PARAM_OUTPUT_DIR}orb.yml"
