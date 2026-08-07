#!/bin/bash
ORB_DIR=${ORB_VAL_ORB_DIR%/}
ORB_FILE=${ORB_VAL_ORB_FILE_NAME#/}

if [ -n "${CIRCLE_TOKEN}" ]; then
    mkdir -p "$ORB_VAL_ORB_DIR" &&
      circleci orb pack --token "${CIRCLE_TOKEN}" --skip-update-check "$ORB_VAL_SOURCE_DIR" >"${ORB_DIR}/${ORB_FILE}"
else
  mkdir -p "$ORB_VAL_ORB_DIR" &&
    circleci orb pack --skip-update-check "$ORB_VAL_SOURCE_DIR" >"${ORB_DIR}/${ORB_FILE}"
fi
