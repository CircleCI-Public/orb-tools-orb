#!/bin/bash
# Use this tool to assist in migrating your Orb Development Kit pipeline.

# Backup the existing files in .circleci/
for file in .circleci/*; do
  if [ -f "$file" ]; then
    mv "$file" "$file.bak"
  fi
done

ORB_TEMPLATE_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} "https://github.com/CircleCI-Public/Orb-Project-Template/releases/latest" | sed 's:.*/::' | xargs)
ORB_TEMPLATE_DOWNLOAD_URL="https://github.com/CircleCI-Public/Orb-Project-Template/archive/refs/tags/${ORB_TEMPLATE_VERSION}.tar.gz"
ORB_TEMP_DIR=$(mktemp -d)

curl -Ls "$ORB_TEMPLATE_DOWNLOAD_URL" -o "$ORB_TEMP_DIR/orb-project-template.tar.gz"
tar -xzf "$ORB_TEMP_DIR/orb-project-template.tar.gz" -C "$ORB_TEMP_DIR"
cp -r "${ORB_TEMP_DIR}/orb-project-template/.circleci/*" .circleci/

read -rp 'Namespace: ' ORB_NAMESPACE
read -rp 'Orb name: ' ORB_NAME
read -rp 'Context name: ' ORB_CONTEXT_NAME

sed -i'.bak' "s/<namespace>/$ORB_NAMESPACE/g" .circleci/config.yml
sed -i'.bak' "s/<orb-name>/$ORB_NAME/g" .circleci/config.yml
sed -i'.bak' "s/<publishing-context>/$ORB_CONTEXT_NAME/g" .circleci/config.yml

sed -i'.bak' "s/<namespace>/$ORB_NAMESPACE/g" .circleci/test-deploy.yml
sed -i'.bak' "s/<orb-name>/$ORB_NAME/g" .circleci/test-deploy.yml
sed -i'.bak' "s/<publishing-context>/$ORB_CONTEXT_NAME/g" .circleci/test-deploy.yml

echo "Successfully upgraded config files."
echo "You must now open \"test-deploy.yml\" and add your integrations tests."
echo "Docs: https://circleci.com/docs/2.0/testing-orbs/#integration-testing"
echo
echo "When complete, delete the '.bak' files in the .circleci directory."
echo 'Commit your changes and the next version of your orb will be published when a tag is created.'

rm -f "$0"
