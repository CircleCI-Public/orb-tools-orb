# this file is for the development of the shellcheck command and will be removed before being merged into the final product. This simply makes it easier to test the scripts locally before adding to the orb command.
# Set colors for terminal output
term_red=$'\e[1;31m'
term_green=$'\e[1;32m'
term_end=$'\e[0m'

ORB_SOURCE_FILES="./*.yml"
SC_ERROR_COUNT=0

###
# For each file
###
for file in $ORB_SOURCE_FILES
do
  # Get the number of steps
  echo -----
  echo "Scanning $file"
  ORB_STEP_COUNT=$(yq r $file --length steps)
  i=0
  while [[ $i -lt $ORB_STEP_COUNT ]]
    ###
    # For each step in that file
    ###
  do
    if [[ $(yq r $file steps[$i].run.command) ]]; then
      ###
      # If that step is a "run" step with a "command" key
      ###
      # EXCLUSIONS
        # SC2148 - Missing shebang, this is to be expected.
        # SC1044 - "<<" parameter notation before the text replacement will appear like a here document with no EOF. Ignore this error for now.
        # SC1072 - Not entirely sure on this one: https://github.com/koalaman/shellcheck/wiki/SC1072. Temporarily adding.
      yq r $file steps[$i].run.command | shellcheck -e SC2148 -e SC1044 -e SC1072 -
      if [[ $? == 1 ]]; then
        # When an error is discovered
        printf "${term_red}Error discovered in $file at step $(($i+1))${term_end}\n"
        echo ---
        echo
        ((SC_ERROR_COUNT++))
      fi
    fi
    ((i++))
  done
  echo
done
set -e
if [ $SC_ERROR_COUNT -gt 0 ]; then
  echo -------------------------------------
  printf "${term_red}Shellcheck has discovered errors. Please view and correct the errors shown above.${term_end}\n"
  echo -------------------------------------
  exit 1
else
  echo -------------------------------------
  printf "${term_green}Shellcheck passed.${term_end}\n"
  echo -------------------------------------
  exit 0
fi