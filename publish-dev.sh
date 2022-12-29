#!/bin/bash
# Used to publish a new development version of the orb-tools orb locally, so that the orb may test itself.

circleci orb pack src > orb.yml
circleci orb publish orb.yml circleci/orb-tools@dev:alpha