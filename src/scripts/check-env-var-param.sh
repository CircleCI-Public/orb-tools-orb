if [[ $PARAM == "" ]]; then
  echo "No required environment variables to check; moving on"
else
  IFS="," read -ra PARAMS \<<< $PARAM

  for i in "${PARAMS[@]}"; do
    if [[ -z "${!i}" ]]; then
      echo "ERROR: Missing environment variable {i}" >&2

      if [[ -n $ERR_MSG ]]; then
        echo "<<parameters.error-message>>" >&2
      fi

      exit $EXIT_IF_UNDEFINED
    else
      echo "Yes, ${i} is defined!"
    fi
  done
fi
