#!/bin/bash
# shellcheck disable=SC2016


if [ ! -f /tmp/orb_dev_kit/publishing_message.txt ]; then
  echo "No Publishing message has been found."
  echo "This likely means the publishing scripts have not yet been run."
  echo "Please open an issue: https://github.com/CircleCI-Public/orb-tools-orb/issues"
  exit 1
fi
PR_COMMENT_BODY=$(cat /tmp/orb_dev_kit/publishing_message.txt)

function postGitHubPRComment() {
  # $1 - Body of the comment
  # $2 - PR ID
  curl --request POST \
  -s \
  --url 'https://api.github.com/graphql?=' \
  --header "$GH_HEADER_DATA" \
  --data '{"query":"mutation AddCommentToPR($body: String!, $sid: String!) {\n  addComment(input: {\n    body: $body,\n    subjectId: $sid\n  }) {\n    clientMutationId\n  }\n}","variables":{"body":"'"$1"'","sid":"'"$2"'"},"operationName":"AddCommentToPR"}'
}

function getGithubPRFromCommit() {
  curl --request POST \
  -s \
  --url 'https://api.github.com/graphql?=' \
  --header "$GH_HEADER_DATA" \
  --data '{"query":"query SearchForPR($query: String!) {\n  search(query: $query, type: ISSUE, first: 3) {\n    issueCount\n    edges {\n      node {\n        ... on  PullRequest {\n         \tid\n          title\n          number\n        }\n    }\n  }\n }\n}","variables":{"query":"'"$CIRCLE_SHA1"' is:pr"},"operationName":"SearchForPR"}'
}

function isAuthenticatedGitHub() {
  curl --request POST \
  -s \
  --url 'https://api.github.com/graphql?=' \
  --header "$GH_HEADER_DATA" \
  --data '{"query":"query IsAuthenticated {\n  viewer {\n    login\n  }\n}","variables":{},"operationName":"IsAuthenticated"}'
}

function mainGitHub() {
  echo "Checking if authenticated to GitHub..."
  if [[ "$(isAuthenticatedGitHub | jq -e '.data.viewer.login')" != "null" ]]; then
    echo "Authenticated!"
    echo "Authenticated as: $(isAuthenticatedGitHub | jq -r '.data.viewer.login')"
    FetchedPRData="$(getGithubPRFromCommit)"
    echo "DEBUG: FetchedPRData: $FetchedPRData"
    # Fetch the PR ID from the commit
    if [ "$(echo "$FetchedPRData" | jq -e '.data.search.issueCount | length > 0')" ]; then
      # PR Found
      PR_COUNT=$(echo "$FetchedPRData" | jq -e '.data.search.issueCount')
      echo "$PR_COUNT PR(s) found!"
      PR_TITLE=$(echo "$FetchedPRData" | jq -er '.data.search.edges[0].node.title')
      PR_NUMBER=$(echo "$FetchedPRData" | jq -er '.data.search.edges[0].node.number')
      PR_ID=$(echo "$FetchedPRData "| jq -er '.data.search.edges[0].node.id')
      echo "Selecting PR: $PR_TITLE (#$PR_NUMBER)"
      echo "Posting comment to PR..."
      postGitHubPRComment "$PR_COMMENT_BODY" "$PR_ID"
      echo "Comment posted!"
    else
      echo "No PR found!"
      echo "It may be that the PR has not yet been created from this commit at the time of this build."
      echo "If you have recently created a PR, subsequent code pushes should properly identify the PR."
      echo "Skipping commenting..."
    fi

  else
    echo "Not authenticated."
    echo "Please set the GITHUB_TOKEN environment variable to your GitHub personal access token."
    exit 1
  fi
}

if [[ "$PIPELINE_VCS_TYPE" == "gh" || "$PIPELINE_VCS_TYPE" == "github" ]]; then
  # GitHub PR Comment Process
  echo "Fetching token value from PARAM_GITHUB_TOKEN..."
  echo "DEBUG: PARAM_GITHUB_TOKEN: $PARAM_GITHUB_TOKEN"
  PARAM_GH_TOKEN_VALUE=${!PARAM_GH_TOKEN}
  echo "$PARAM_GH_TOKEN_VALUE" >> /tmp/orb_dev_kit/github_token.txt
  GH_HEADER_DATA="Authorization: Bearer $PARAM_GH_TOKEN_VALUE"
  mainGitHub
elif [[ "$PIPELINE_VCS_TYPE" == "bb" || "$PIPELINE_VCS_TYPE" == "bitbucket" ]]; then
  echo "BitBucket PR Comments are not yet supported. Skipping."
  exit 0
else
  echo "Unsupported VCS type: $PIPELINE_VCS_TYPE"
  exit 0
fi