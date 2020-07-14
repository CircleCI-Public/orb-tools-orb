if [ -z "$GIT_CONFIG_USER_NAME" ] || [ -z "$GIT_CONFIG_USER_EMAIL" ]; then
    # No user name or email set, default to CIRCLE_USERNAME-based identifiers
    git config --global user.name "$CIRCLE_USERNAME"
    git config --global user.email "$CIRCLE_USERNAME@users.noreply.github.com"
else
    git config --global user.name ${<< parameters.git-config-user-name >>}
    git config --global user.email ${<< parameters.git-config-user-email >>}
fi
