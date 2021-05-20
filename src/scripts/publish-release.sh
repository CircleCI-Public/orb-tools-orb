#!/bin/bash
# If GitHub features are enabled.
ORB_PARAM_DEV_ORB=${ORB_PARAM_ORB_NAME}@dev:${CIRCLE_SHA1}

if [ "$ORB_PARAM_FEATURES_GITHUB" == 0 ]; then
	echo "Creating GitHub Tag and Release for orb"
	echo "Publishing ${ORB_PARAM_DEV_ORB} as ${ORB_PARAM_ORB_NAME}@${ORB_PARAM_ORB_TAG}"
fi
