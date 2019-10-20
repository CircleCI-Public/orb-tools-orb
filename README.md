# Orb Tools Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/orb-tools-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/orb-tools-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/orb-tools)](https://circleci.com/orbs/registry/orb/circleci/orb-tools) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/orb-tools-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

An orb for orb authors.

## Usage

_For full usage guidelines, see the [orb registry listing](http://circleci.com/orbs/registry/orb/circleci/orb-tools)._

### Example

Following is a well-documented example of a full orb development pipeline, consisting of two workflows and making use of multiple jobs from this orb. For further details/discussion, see [Creating Automated Build/Test/Deploy Workflows for Orbs](https://circleci.com/blog/creating-automated-build-test-and-deploy-workflows-for-orbs), on the CircleCI Blog.

```yaml
version: 2.1

orbs:
  orb-tools: circleci/orb-tools@x.y.z
  # add your orb below, to be used in integration tests (note: a
  # @dev:alpha release must exist; if none exists, you'll need to
  # publish manually once before this workflow can succeed)
  your-orb: your-namespace/your-orb@dev:alpha

workflows:
  lint_pack-validate_publish-dev:
    jobs:
      # this `lint-pack_validate_publish-dev` workflow will run on any commit
      - orb-tools/lint

      # pack your orb YAML files to a single orb.yml
      # validate the orb.yml file to ensure it is well-formed
      - orb-tools/pack:
          requires:
            - orb-tools/lint

      # release dev version of orb, for testing & possible publishing
      # requires a CircleCI API token to be stored as CIRCLE_TOKEN (default)
      # https://circleci.com/docs/2.0/managing-api-tokens
      # store CIRCLE_TOKEN as a project env var or Contexts resource
      # if using Contexts, add your context below
      - orb-tools/publish-dev:
          orb-name: your-namespace/your-orb-name
          requires:
            - orb-tools/pack

      # trigger an integration workflow to test the dev version of your orb
      # an SSH key must be stored in your orb's repository and in CircleCI
      # (add the public key as a read/write key on GitHub; add the private
      # key in CircleCI via SSH Permissions, with github.com as Hostname)
      - orb-tools/trigger-integration-workflow:
          name: trigger-integration-dev
          ssh-fingerprints: your-SSH-fingerprints
          requires:
            - orb-tools/publish-dev
          filters:
            branches:
              ignore: master

      # by default, the 1st job (above) will trigger only integration tests;
      # the 2nd job (below) may also publish a production orb version
      - orb-tools/trigger-integration-workflow:
          name: trigger-integration-master
          ssh-fingerprints: your-SSH-fingerprints
          tag: master
          requires:
            - orb-tools/publish-dev
          filters:
            branches:
              only: master

  # this `integration-tests_prod-release` workflow will ignore commits
  # it is only triggered by git tags, which are created in the job above
  integration-tests_prod-release:
    jobs:
      # your integration test jobs go here: essentially, run all your orb's
      # jobs and commands to ensure they behave as expected. or, run other
      # integration tests of your choosing

      # this would need to be defined in a `jobs` section (not shown here)
      - integration-tests:
          name: integration-tests-dev
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /integration-.*/

      # call jobs twice, once for workflows resulting from non-master-branch
      # commits (above); once for commits to master (below)
      - integration-tests:
          name: integration-tests-master
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /master-.*/

      # patch, minor, or major publishing, depending on which orb source
      # files have been modified (that logic lives in the
      # trigger-integration-workflow job's source)
      - orb-tools/dev-promote-prod:
          name: dev-promote-patch
          orb-name: your-namespace/your-orb
          requires:
            - integration-tests-master
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /master-patch.*/

      - orb-tools/dev-promote-prod:
          name: dev-promote-minor
          release: minor
          orb-name: your-namespace/your-orb
          requires:
            - integration-tests-master
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /master-minor.*/

      - orb-tools/dev-promote-prod:
          name: dev-promote-major
          release: major
          orb-name: your-namespace/your-orb
          requires:
            - integration-tests-master
          filters:
            branches:
              ignore: /.*/
            tags:
              only: /master-major.*/
```

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/orb-tools-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/orb-tools-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/ecosystem/orbs).
