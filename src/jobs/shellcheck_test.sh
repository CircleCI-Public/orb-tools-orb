# this file is for the development of the shellcheck command and will be removed before being merged into the final product. This simply makes it easier to test the scripts locally before adding to the orb command.
ORB_SOURCE_FILES="./*.yml"
SC_ERROR_COUNT=0
for file in $ORB_SOURCE_FILES # For every file
do
  # Get the number of steps
  echo -----
  echo "Scanning $file"
  ORB_STEP_COUNT=$(yq r $file --length steps)
  i=0
  while [[ $i -lt $ORB_STEP_COUNT ]]
  do
    if [[ $(yq r $file steps[$i].run.command) ]]; then
      yq r $file steps[$i].run.command
      yq r $file steps[$i].run.command | shellcheck -
      if [$? -gt 0]; then
        echo "Error discovered in $file at step $i"
        echo ---
        echo
        SC_ERROR_COUNT=$SC_ERROR_COUNT+1
      fi
    fi
    ((i = i + 1))
  done
  echo
done
set -e
if [ $SC_ERROR_COUNT -gt 0 ]; then
  echo -------------------------------------
  echo Shellcheck has discovered errors. Please view and correct the errors shown above.
  echo -------------------------------------
  exit 1
else
  echo -------------------------------------
  echo Shellcheck passed.
  echo -------------------------------------
  exit 0
fi