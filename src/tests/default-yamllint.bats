@test '1: Create a Yaml Lint file' {
  # ensure the script runs
  run . ./src/scripts/default-yamllint.sh
  [ "$status" -eq 0 ]
  # Check the size/contents to ensure not an empty file
  [ "8" -eq $(du .yamllint | cut -f1) ]
}