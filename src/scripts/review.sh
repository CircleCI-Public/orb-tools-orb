#!/bin/bash
if ! command -v bats; then
	echo 'The "bats-core" automation framework must be installed to execute review testing.'
	exit 1
fi
if ! command -v COMMAND &> /dev/null; then
	pip3 install yq -q
fi
mkdir -p /tmp/orb_review
echo "$ORB_REVIEW_BATS_FILE "> review.bats
echo "Reviewing orb best practices"
echo "If required, tests can be skipped via their \"RCXXX\" code with the \"exclude\" parameter."
bats --tap ./review.bats