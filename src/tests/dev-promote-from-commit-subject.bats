setup() {
    source ./src/scripts/dev-promote-from-commit-subject.sh
    export T="fakeToken"
    export REF="55555555"
    export BASH_ENV=/tmp/BASH_ENV
}

@test 'Promote From Commit Subject 1: Test GetIncrement Major' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:major]"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="major"' $BASH_ENV
}

@test 'Promote From Commit Subject 2: Test GetIncrement Minor' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:minor]"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="minor"' $BASH_ENV
}

@test 'Promote From Commit Subject 3: Test GetIncrement patch' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:patch]"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="patch"' $BASH_ENV
}

@test 'Promote From Commit Subject 4: Test GetIncrement Skip' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:skip]"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="skip"' $BASH_ENV
}

@test 'Promote From Commit Subject 5: Disallow Other Increment Strings' {
    export COMMIT_SUBJECT="Test CircleCI Orb [semver:null]"
    GetIncrement
    [[ -z $(cat $BASH_ENV | grep 'SEMVER_INCREMENT="null"') ]]

}

@test 'Promote From Commit Subject 6: Test CheckIncrement Major' {
    export ORB_VERSION=test
    export SEMVER_INCREMENT="major"
    function PublishOrb() { echo "Mock Publishing"; }
    export -f PublishOrb
    CheckIncrement
    cat $BASH_ENV
    grep -e 'export PR_MESSAGE="BotComment: \*Production\* version of orb available for use - \\`test\\`\"' $BASH_ENV

}

@test 'Promote From Commit Subject 7: Test GetIncrement default to major' {
    export COMMIT_SUBJECT="Test CircleCI Orb"
    export DEFAULT_SEMVER_INCREMENT="major"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="major"' $BASH_ENV
}

@test 'Promote From Commit Subject 7: Test GetIncrement default to minor' {
    export COMMIT_SUBJECT="Test CircleCI Orb"
    export DEFAULT_SEMVER_INCREMENT="minor"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="minor"' $BASH_ENV
}

@test 'Promote From Commit Subject 7: Test GetIncrement default to patch' {
    export COMMIT_SUBJECT="Test CircleCI Orb"
    export DEFAULT_SEMVER_INCREMENT="patch"
    GetIncrement
    grep -e 'SEMVER_INCREMENT="patch"' $BASH_ENV
}


function teardown() {
    rm -rf .command_functions /tmp/BASH_ENV
}
