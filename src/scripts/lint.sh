#!/bin/bash
if [ ! -d "./src" ]; then
	echo "No source directory located at ./src"
	echo "This orb assumes you have build your orb using the Orb Development Kit"
	echo "https://circleci.com/docs/2.0/orb-author/#orb-development-kit"
fi
pip install --user yamllint
yamllint ./src
