if [[ <<parameters.param>> == "" ]]; then
  echo "No required environment variables to check; moving on"
else
  IFS="," read -ra PARAMS \<<< "<<parameters.param>>"

  for i in "${PARAMS[@]}"; do
    if [[ -z "${!i}" ]]; then
      echo "ERROR: Missing environment variable {i}" >&2

      if [[ -n "<<parameters.error-message>>" ]]; then
        echo "<<parameters.error-message>>" >&2
      fi

      <<#parameters.exit-if-undefined>>exit 1<</parameters.exit-if-undefined>>
    else
      echo "Yes, ${i} is defined!"
    fi
  done
fi
