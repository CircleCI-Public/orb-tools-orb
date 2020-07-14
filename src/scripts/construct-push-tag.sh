# construct/push new tag
NEW_VERSION=$(echo ${ORB_VERSION}| sed -E "s|$ORB_NAME@||")

TAG="v$NEW_VERSION"

git tag -a "$TAG" \
-m "View this orb release in the orb registry:" \
-m "https://circleci.com/orbs/registry/orb/$ORB_NAME?version=$NEW_VERSION" \
-m "View this orb release using the CircleCI CLI:" \
-m "\`circleci orb source $ORB_NAME@$NEW_VERSION\`"

git push origin "$TAG"