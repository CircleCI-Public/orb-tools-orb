#!/bin/bash
if [ ! -d "$ORB_PARAM_SOURCE_DIR" ]; then
	echo "No source directory located at $ORB_PARAM_SOURCE_DIR"
	echo "This orb assumes you have built your orb using the Orb Development Kit"
	echo "https://circleci.com/docs/2.0/orb-author/#orb-development-kit"
fi
pip install --user yamllint
yamllint "$ORB_PARAM_SOURCE_DIR"
