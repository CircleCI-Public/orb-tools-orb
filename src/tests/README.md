# Testing Orbs

The orb-tools orb is built using the `circleci orb pack` command, which allows the _command_ logic to be separated out into separate _shell script_ `.sh` files. Because the logic now sits in a known and executable language, it is possible to perform true unit testing using existing frameworks such a [BATS](https://github.com/bats-core/bats-core#installing-bats-from-source).