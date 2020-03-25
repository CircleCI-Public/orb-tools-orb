# Orb Tools Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/orb-tools-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/orb-tools-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/orb-tools)](https://circleci.com/orbs/registry/orb/circleci/orb-tools) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/orb-tools-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

An orb for orb authors.

## Usage

_For full usage guidelines, see the [orb registry listing](http://circleci.com/orbs/registry/orb/circleci/orb-tools)._

### Example

Following is a well-documented example of a full orb development pipeline, consisting of two workflows and making use of multiple jobs from this orb. For further details/discussion, see [Creating Automated Build/Test/Deploy Workflows for Orbs](https://circleci.com/blog/creating-automated-build-test-and-deploy-workflows-for-orbs), on the CircleCI Blog. (However, note that currently the aforementioned blog article references an older version of the orb)

```yaml
version: 2.1

orbs:
  orb-tools: circleci/orb-tools@x.y.z
  # add your orb below, to be used in integration tests (note: a
  # @dev:alpha release must exist; if none exists, you'll need to
  # publish manually once before this worklow can succeed)
  your-orb: your-namespace/your-orb@<<pipeline.parameters.dev-orb-version>>

# Pipeline parameters
parameters:
  # These pipeline parameters are required by the "trigger-integration-tests-workflow"
  # job, by default.
  run-integration-tests:
    type: boolean
    default: false
  dev-orb-version:
    type: string
    default: "dev:alpha"

jobs:
  integration-tests-for-your-orb:
    executor: orb-tools/ubuntu
    steps:
      - checkout
    # Test your orb e.g.
    # - your-orb/your-orb-command

workflows:
  lint_pack-validate_publish-dev:
    unless: << pipeline.parameters.run-integration-tests >>
    jobs:
      # this `lint-pack_validate_publish-dev` workflow will run on any commit
      - orb-tools/lint

      # pack your orb YAML files to a single orb.yml
      # validate the orb.yml file to ensure it is well-formed
      - orb-tools/pack:
          requires:
            - orb-tools/lint

      # release dev version of orb, for testing & possible publishing.
      # orb will be published as dev:alpha and dev:${CIRCLE_SHA1:0:7}.
      # requires a CircleCI API token to be stored as CIRCLE_TOKEN (default)
      # https://circleci.com/docs/2.0/managing-api-tokens
      # store CIRCLE_TOKEN as a project env var or Contexts resource
      # if using Contexts, add your context below
      - orb-tools/publish-dev:
          orb-name: your-namespace/your-orb-name
          requires:
            - orb-tools/pack

      # trigger an integration workflow to test the
      # dev:${CIRCLE_SHA1:0:7} version of your orb
      - orb-tools/trigger-integration-tests-workflow:
          name: trigger-integration-dev
          requires:
            - orb-tools/publish-dev

  # This `integration-tests_prod-release` workflow will only run
  # when the run-integration-tests pipeline parameter is set to true.
  # It is meant to be triggered by the "trigger-integration-tests-workflow"
  # job, and run tests on <your orb>@dev:${CIRCLE_SHA1:0:7}.
  integration-tests_prod-release:
    when: << pipeline.parameters.run-integration-tests >>
    jobs:
      # your integration test jobs go here: essentially, run all your orb's
      # jobs and commands to ensure they behave as expected. or, run other
      # integration tests of your choosing

      # an example job
      - integration-tests-for-your-orb

      # publish a semver version of the orb. relies on
      # the commit subject containing the text "[semver:patch|minor|major|skip]"
      # as that will determine whether a patch, minor or major
      # version will be published or if publishing should
      # be skipped.
      # e.g. [semver:patch] will cause a patch version to be published.
      - orb-tools/dev-promote-prod-from-commit-subject:
          orb-name: your-namespace/your-orb
          add-pr-comment: false
          publish-version-tag: false
          fail-if-semver-not-indicated: false
          requires:
            - integration-tests-for-your-orb
          filters:
            branches:
              only: master

```

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/orb-tools-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/orb-tools-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/ecosystem/orbs).
