# Testing Orbs

The orb-tools orb is built using the `circleci orb pack` command, which allows the _command_ logic to be separated out into separate _shell script_ `.sh` files. Because the logic now sits in a known and executable language, it is possible to perform true unit testing using existing frameworks such a [BATS](https://github.com/bats-core/bats-core#installing-bats-from-source).

**Example _command.yml_**

```yaml

description: A sample command

parameters:
  source:
    description: "source path parameter example"
    type: string
    default: src

steps:
  - run:
      name: "Ensure destination path"
      environment:
        ORB_SOURCE_PATH: <<parameters.source>>
      command: <<include(scripts/command.sh)>>
```
<!--- <span> is used to disable the automatic linking to a potential website. --->
**Example _command<span>.sh_**

```bash

CreatePackage() {
    cd "$ORB_SOURCE_PATH" && make
    # Build some application at the source location
    # In this example, let's assume given some
    # sample application and known inputs,
    # we expect a certain logfile would be generated.
}

# Will not run if sourced from another script.
# This is done so this script may be tested.
if [[ "$_" == "$0" ]]; then
    CreatePackage
fi

```

**Example _command_tests.bats_**

```bash
# Runs prior to every test
setup() {
    # Load functions from our script file.
    # Ensure the script will not execute as
    # shown in the above script example.
    source ./src/scripts/command.sh
}

@test '1: Test Build Results' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export ORB_SOURCE_PATH="src/my-sample-app"
    CreatePackage
    # test the results
    grep -e 'RESULT="success"' log.txt
}

```