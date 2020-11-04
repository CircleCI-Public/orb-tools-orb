PR_NUMBER=$(git log -1 --pretty=%s. | sed -n "$SED_EXP")
echo "PR_NUMBER is ${PR_NUMBER}"
if [ "$PR_NUMBER" == "" ];then
    echo "No pr found; do nothing. If this is a mistake, check if your PR commit message matches the $SED_EXP sed expression."
    exit 0
fi
curl -X POST -u "${BOT_USER}:${BOT_TOKEN}" "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/issues/${PR_NUMBER}/comments" -d "{\"body\":\"${COMMENT}\"}"
