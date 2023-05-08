#!/bin/bash
# Use this tool to assist in migrating your Orb Development Kit pipeline from v11+ to v12+.

orb_config_files=(
  ".circleci/config.yml"
  ".circleci/test-deploy.yml"
)
component_types=("commands" "executors" "jobs" "examples")
orb_name=""
declare -a token_map

verify_run() {
  CHECK_FAILED=false
  # Ensure .circleci/config.yml exists
  if [ ! -f "${orb_config_files[0]}" ]; then
    echo "No .circleci/config.yml found"
    echo "This does not appear to be the root of a CircleCI project"
    CHECK_FAILED=true
  fi

  # Ensure .circleci/test-deploy.yml exists
  if [ ! -f "${orb_config_files[1]}" ]; then
    echo "No .circleci/test-deploy.yml found"
    echo "This version of the migration tool expects your orb to have been built with Orb-Tools v11 or higher. If you are upgrading from an earlier version of orb tools, you must first upgrade to v11+ by using the v11 version of this tool from https://github.com/CircleCI-Public/orb-tools-orb/tree/v11.6.1"
    CHECK_FAILED=true
  fi

  # Ensure yq is installed
  if ! command -v yq >/dev/null 2>&1; then
    echo "Looks like you don't have \"yq\" installed"
    echo "Please install it and run the script again: https://github.com/mikefarah/yq#install."
    CHECK_FAILED=true
  fi

  # Warn the user to backup their files
  if [ "$CHECK_FAILED" == false ]; then
    echo "This script will rename all your orb components and parameters to use snake_case."
    echo "Yaml files will be standardized to .yml."
    echo "Please backup your files or create a new branch before running this script."
    echo
    read -rp 'Continue? [y/N] ' CONTINUE
    if [ "$CONTINUE" != "y" ]; then
      echo "Exiting..."
      exit 1
    fi
  fi

  if [ "$CHECK_FAILED" == true ]; then
    exit 1
  fi
}

# Gets all the YAML files in the src/<component> directory
get_components() {
  # Return an array of command names as given by the filename in `src/<component>/`
  local -a component_names
  component_dir="./src/${1}"
  for file in "${component_dir}"/*.yaml "${component_dir}"/*.yml; do
    if [ -f "$file" ]; then
      component_names+=("$file")
    fi
  done
  echo "${component_names[@]}"
}

convert_to_snake_case() {
  # Convert the string to snake_case
  echo "$1" | sed -E 's/-/_/g' | tr '[:upper:]' '[:lower:]'
}

# Takes in a list of files and renames them to snake_case and standardizes the file extension to .yml
rename_components() {
  for file in ${1}; do
    # Get the filename without the extension
    filename=$(basename -- "$file")
    filename="${filename%.*}"
    token_map+=("$filename")
    # Convert the filename to snake_case
    filename=$(convert_to_snake_case "$filename")
    filepath=$(dirname "$file")
    # Rename the file
    if [ -d ".git" ]; then
      git mv "$file" "${filepath}/${filename}.yml" 2>/dev/null
    else
      mv "$file" "${filepath}/${filename}.yml" 2>/dev/null
    fi
  done
}

destroy_script() {
  rm -f "$0"
}

find_and_replace() {
  #1 the file
  #2 the string to find
  #3 the string to replace it with
  sed -i "" -e "s/$2/$3/g" "$1"
}

main() {
  # Set the orb name
  read -rp 'Enter the name of your orb: ' orb_name
  # Get and rename all orb components and add them to the token map
  for component_type in "${component_types[@]}"; do
    components=$(get_components "${component_type}")
    echo "Renaming ${component_type}..."
    for component in ${components}; do
      # The component is renamed and added to the token map
      rename_components "${component}"
    done
  done

  # Get all orb component parameter keys and add them to the token map
  for component_type in "${component_types[@]}"; do
    components=$(get_components "${component_type}")
    echo "Fetching ${component_type} parameter keys..."
    for component in ${components}; do
      keys=$(yq -e '.parameters | keys | .[]' "$component" 2>/dev/null)
      for key in ${keys}; do
        token_map+=("$key")
        # # find_and_replace "$component" "$key" "$(convert_to_snake_case "$key")"
      done
    done
  done

  # Find and replace all tokens in the orb components
  for component_type in "${component_types[@]}"; do
    components=$(get_components "${component_type}")
    echo "Replacing tokens in ${component_type}..."
    for component in ${components}; do
      for token in "${token_map[@]}"; do
        find_and_replace "$component" "$token" "$(convert_to_snake_case "$token")"
      done
    done
  done

  # Find and replace all tokens in the orb config files
  for orb_config_file in "${orb_config_files[@]}"; do
    echo "Replacing tokens in ${orb_config_file}..."
    for token in "${token_map[@]}"; do
      find_and_replace "$orb_config_file" "$token" "$(convert_to_snake_case "$token")"
    done
  done

  # Remove the orb import from the test-deploy.yml file
  echo "Removing orb import from ${orb_config_files[1]}..."
  ORB_IMPORT_KEY=$(yq eval ".orbs | to_entries | map(select(.value == \"*${orb_name}*\")) | .[0].key" "${orb_config_files[1]}" 2>/dev/null)
  if [ -n "$ORB_IMPORT_KEY" ]; then
    yq eval "del(.orbs.${ORB_IMPORT_KEY})" -i "${orb_config_files[1]}"
  else
    echo "Could not find orb import in ${orb_config_files[1]}"
    echo "Please remove the import manually."
  fi

}

verify_run
main
echo "Migration complete!"
destroy_script
