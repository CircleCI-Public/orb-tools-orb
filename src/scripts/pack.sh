#!/bin/bash
mkdir -p "$ORB_PARAM_OUTPUT_DIR" && circleci orb pack --skip-update-check "$ORB_PARAM_SOURCE_DIR" >"${ORB_PARAM_OUTPUT_DIR}/${ORB_PARAM_OUTPUT_FILENAME}"
