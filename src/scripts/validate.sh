#!/bin/bash
circleci orb validate --host "${CIRCLECI_API_HOST}" --token "${CIRCLE_TOKEN}" --skip-update-check "${ORB_PARAM_OUTPUT_DIR}orb.yml"
