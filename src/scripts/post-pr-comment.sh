PR_NUMBER=`git log -1 --pretty=%s. | sed -n '<<parameters.pr-number-sed-expression>>'`
echo "PR_NUMBER is ${PR_NUMBER}"
if [ "$PR_NUMBER" == "" ];then
    echo "No pr found; do nothing. If this is a mistake, check if your PR commit message matches the <<parameters.pr-number-sed-expression>> sed expression."
    exit 0
fi
curl -X POST -u "<<parameters.bot-user>>:$<<parameters.bot-token-variable>>" "https://api.github.com/repos/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}/issues/${PR_NUMBER}/comments" -d "{\"body\":\"<<parameters.comment>>\"}"
