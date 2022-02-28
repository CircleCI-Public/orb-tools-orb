#!/bin/bash
if ! command -v bats >/dev/null; then
	echo 'The "bats-core" automation framework must be installed to execute review testing.'
	echo 'Install bats with the bats orb'
	exit 1
fi
if ! command -v yq >/dev/null; then
	echo 'The "yq" package must be installed to execute review testing.'
	echo 'Installing "yq" automatically...'
	YQ_VERSION=v4.20.1
	YQ_BIN=yq_linux_amd64
	wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BIN}.tar.gz -O - |
		tar xz && mv ${YQ_BIN} /usr/bin/yq
fi

mkdir -p /tmp/orb_dev_kit/review/
echo "$ORB_REVIEW_BATS_FILE " >review.bats
echo "Reviewing orb best practices"
echo "If required, tests can be skipped via their \"RCXXX\" code with the \"exclude\" parameter."
EXIT_CODE=0
bats -T --formatter junit ./review.bats >/tmp/orb_dev_kit/review/review.xml || EXIT_CODE=$?
echo "Review complete!"
echo "Review the results in the \"TESTS\" tab above. If you would like to ignore any of the suggestions, add their \"RCXXX\" code to the \"exclude\" parameter."
exit $EXIT_CODE
