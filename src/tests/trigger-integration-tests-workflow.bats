setup() {
    source ./src/scripts/trigger-integration-tests-workflow.sh
    export T="fakeToken"
    export VCS_TYPE="gh"
    export BASH_ENV=/tmp/BASH_ENV
}

@test 'Trigger Integration Tests Workflow 1: Test BuildParams' {
    export PARAM_MAP='{\"x\": \"y\"}'
    export CIRCLE_BRANCH='bats-testing'
    BuildParams
    grep -e '{"branch": "bats-testing", "parameters": {"x": "y"}}' pipelineparams.json
}

@test 'Trigger Integration Tests Workflow 2: Test Result handling' {
    echo '{"number": 1}' > /tmp/curl-result.txt
    Result
}

function teardown() {
    rm pipelineparams.json
    rm /tmp/curl-result.txt
    rm -rf .command_functions /tmp/BASH_ENV
}