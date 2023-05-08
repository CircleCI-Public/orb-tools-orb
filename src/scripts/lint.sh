#!/bin/bash
if [ ! -d "$ORB_VAL_SOURCE_DIR" ]; then
    printf "No source directory located at %s\n" "$ORB_VAL_SOURCE_DIR"
    printf "This orb assumes you have built your orb using the Orb Development Kit\n"
    printf "https://circleci.com/docs/2.0/orb-author/#orb-development-kit\n"
    exit 1
fi
pip install --user yamllint
yamllint "$ORB_VAL_SOURCE_DIR"
