setup() {
    source ./src/scripts/dev-promote-from-git-tag.sh
    export T="fakeToken"
    export REF="55555555"
    export BASH_ENV=/tmp/BASH_ENV
    export MAJOR_RELEASE_TAG_REGEX="^major-release-v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$"
    export MINOR_RELEASE_TAG_REGEX="^minor-release-v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$"
    export PATCH_RELEASE_TAG_REGEX="^patch-release-v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$"
}

@test 'Promote From Git Tag 1: Test Major Tag' {
    export CIRCLE_TAG="major-release-v1.0.0"
    DiscoverTag
    grep -e 'RELEASE_TYPE="major"' $BASH_ENV
}

@test 'Promote From Git Tag 2: Test Minor Tag' {
    export CIRCLE_TAG="minor-release-v1.1.0"
    DiscoverTag
    grep -e 'RELEASE_TYPE="minor"' $BASH_ENV
}

@test 'Promote From Git Tag 3: Test Patch Tag' {
    export CIRCLE_TAG="patch-release-v1.1.1"
    DiscoverTag
    grep -e 'RELEASE_TYPE="patch"' $BASH_ENV
}

function teardown() {
    rm -rf .command_functions /tmp/BASH_ENV
}