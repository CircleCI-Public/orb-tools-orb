Setup() {
    VCS_TYPE=$(echo "${CIRCLE_BUILD_URL}" | cut -d '/' -f 4)
    T=$(eval echo "$TOKEN")
    eval echo $PARAM_MAP > pipelineparams.json
}

DoCurl() {
    curl -u "${T}": -X POST --header "Content-Type: application/json" -d @pipelineparams.json \
      "https://circleci.com/api/v2/project/${VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/pipeline" -o /tmp/curl-result.txt
}

Result() {
    CURL_RESULT=$(cat /tmp/curl-result.txt)
    if [[ $(echo "$CURL_RESULT" | jq -r .message) == "Not Found" || $(echo "$CURL_RESULT" | jq -r .message) == "Permission denied" || $(echo "$CURL_RESULT" | jq -r .message) == "Project not found" ]]; then
        echo "Was unable to trigger integration test workflow. API response: $(cat /tmp/curl-result.txt | jq -r .message)"
        exit 1
    else
        echo "Pipeline triggered!"
        echo "https://app.circleci.com/jobs/${VCS_TYPE}/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/$(cat /tmp/curl-result.txt | jq -r .number)"
    fi
}

Main() {
    Setup
    DoCurl
    Result
}

# Will not run if sourced for bats.
# View src/tests for more information.
TEST_ENV="bats-core"
if [ "${0#*$TEST_ENV}" == "$0" ]; then
    Main
fi