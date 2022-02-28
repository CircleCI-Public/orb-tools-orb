# Orb Tools Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/orb-tools-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/orb-tools-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/circleci/orb-tools.svg)](https://circleci.com/orbs/registry/orb/circleci/orb-tools) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/orb-tools-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

An orb for orb authors - provides a full suite of jobs for packing, validating, reviewing, testing and deploying your orbs to the orb registry.

## Usage

The _orb-tools_ orb is a key component of the "[Orb Development Kit](https://circleci.com/docs/2.0/orb-author/#orb-development-kit)". For the full documentation for developing orbs, see the [CircleCI Orb Authoring Process](https://circleci.com/docs/2.0/orb-author/) documentation.

When you initialize a new orb project using the Orb Development Kit, a customized `.circleci/config.yml` file is created containing a full CI pipeline for building, testing, and publishing your orb which utilizes the "orb-tools" orb for the majority of these functions. You can find the config template [here](https://github.com/CircleCI-Public/Orb-Project-Template/).

Once automatically configured, on each code push to your repo, CircleCI will trigger the pipeline defined in the `.circleci/config.yml` file, which will execute (among several others) the orb-tools orb's jobs.

When you are ready to publish a new version of your orb, you can create a new release on GitHub and/or push a [semantically versioned](https://semver.org/) tag.

For the full documentation for Orb Publishing, see the [CircleCI Orb Publishing Process](https://circleci.com/docs/2.0/creating-orbs/) documentation.

### Local Usage

A subset of the orb-tools orb jobs and scripts can be ran locally. It is useful to be able to lint, shellcheck, and review your orbs locally, before committing. We can test nearly anything locally that does not require building and executing the orb directly.

#### Local Linting

The orb-tools orb's `orb-tools/lint` job uses a utility [yamllint](https://yamllint.readthedocs.io/en/stable/), which can be downloaded an ran locally, or you can invoke the job locally with the CircleCI CLI.

Assuming you `./circleci/config.yml` file appears similar to the one in this repository, you will have imported the orb-tools orb and defined the `orb-tools/lint` job in a workflow. Using the CLI from this directory, use the following command to locally lint your orb:

##### CircleCI Local Linting

```shell
$ circleci local execute --job orb-tools/lint
```

##### YamlLint Local Linting

```shell
$ yamllint ./src
```

Note: you will need a `.yamllint` file in the current directory to run the yamllint command. This will also be generated for you by the Orb Development Kit. Preview the file in the [Orb Project Template](https://github.com/CircleCI-Public/Orb-Project-Template).

#### Local Shellcheck

[Shellcheck](https://github.com/koalaman/shellcheck) is a static analysis tool for shell scripts, and behaves like a linter for our shell scripts. Which of course can also be ran locally, or if defined within your configuration file, you can invoke the job locally with the CircleCI CLI.

##### CircleCI Local Shellcheck

```shell
$ circleci local execute --job shellcheck/check
```

You can not however pass in parameters to skip specific checks. Use the Shellcheck CLI locally for more control when running locally.

##### Shellcheck Local Shellcheck

```shell
$ shellcheck ./src/scripts/*.sh --exclude SC2148,SC2038,SC2086,SC2002,SC2016
```

#### Local Review

The `review` job is a suite of Bash unit tests written using [bats-core](https://github.com/bats-core/bats-core), a test automation framework for Bash. Each test focuses on checking for a best practice in the orb. The tests can be executed directly with the `bats` CLI, or you can invoke the job locally with the CircleCI CLI.

##### CircleCI Local Review

```shell
$ circleci local execute --job orb-tools/review
```

**Note:** You will _always_ see a failure at the end of this job when ran locally because the job contains a step to upload test results to CircleCI.com, which is not supported in the local agent.

##### Bats CLI Review

You can also install the `bats-core` package locally and run the tests with the `bats` CLI.

```shell
$ bats ./src/scripts/review.bats
```

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/orb-tools-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/orb-tools-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/ecosystem/orbs).
