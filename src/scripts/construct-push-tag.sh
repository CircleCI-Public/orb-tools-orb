# construct/push new tag
NEW_VERSION=$(echo ${ORB_VERSION}| sed -E 's|<<parameters.orb-name>>@||')

TAG="v$NEW_VERSION"

git tag -a "$TAG" \
-m "View this orb release in the orb registry:" \
-m "https://circleci.com/orbs/registry/orb/<<parameters.orb-name>>?version=$NEW_VERSION" \
-m "View this orb release using the CircleCI CLI:" \
-m "\`circleci orb source <<parameters.orb-name>>@$NEW_VERSION\`"

git push origin "$TAG"