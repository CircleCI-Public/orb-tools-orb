#!/bin/bash
if ! command -v bats; then
	echo 'The "bats-core" automation framework must be installed to execute review testing.'
	exit 1
fi
if ! command -v COMMAND &> /dev/null; then
	pip3 install yq
fi
mkdir -p /tmp/orb_review
echo "$ORB_REVIEW_BATS_FILE "> review.bats
bats --tap ./review.bats