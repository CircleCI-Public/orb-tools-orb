setup() {
    mkdir -p ./.command_functions
    awk -f ./src/tests/funcshion.awk -v path=./.command_functions ./src/scripts/dev-promote-from-commit-subject.sh
    export T="fakeToken"
    export REF="55555555"
    export BASH_ENV=/tmp/BASH_ENV
}

@test '1: Test GetIncrement Major' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:major]"
    source ./.command_functions/dev-promote-from-commit-subject/getincrement
    GetIncrement
    grep -e 'SEMVER_INCREMENT="major"' $BASH_ENV
}

@test '2: Test GetIncrement Minor' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:minor]"
    source ./.command_functions/dev-promote-from-commit-subject/getincrement
    GetIncrement
    grep -e 'SEMVER_INCREMENT="minor"' $BASH_ENV
}

@test '3: Test GetIncrement patch' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:patch]"
    source ./.command_functions/dev-promote-from-commit-subject/getincrement
    GetIncrement
    grep -e 'SEMVER_INCREMENT="patch"' $BASH_ENV
}

@test '4: Test GetIncrement Skip' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:skip]"
    source ./.command_functions/dev-promote-from-commit-subject/getincrement
    GetIncrement
    grep -e 'SEMVER_INCREMENT="skip"' $BASH_ENV
}

@test '5: Disallow Other Increment Strings' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:null]"
    source ./.command_functions/dev-promote-from-commit-subject/getincrement
    GetIncrement
    [[ -z $(cat $BASH_ENV | grep 'SEMVER_INCREMENT="null"') ]]

}

@test '6: Test CheckIncrement Major' {
    export ORB_VERSION=test
    export SEMVER_INCREMENT="major"
    function PublishOrb() { echo "Mock Publishing"; }
    export -f PublishOrb
    source ./.command_functions/dev-promote-from-commit-subject/checkincrement
    CheckIncrement
    cat $BASH_ENV
    grep -e 'export PR_MESSAGE="BotComment: \*Production\* version of orb available for use - \\`test\\`\"' $BASH_ENV

}

function teardown() {
    rm -rf .command_functions .yamllint /tmp/BASH_ENV
}