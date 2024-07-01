#!/bin/bash

# This script is used to run tests for the InfluxDB documentation.
# The script is designed to be run in a Docker container. It is used to substitute placeholder values in test files.

TEST_CONTENT="/app/content"

function substitute_placeholders {
  for file in `find "$TEST_CONTENT" -type f \( -iname '*.md' \)`; do
    if [ -f "$file" ]; then
      # echo "PRETEST: substituting values in $file"

      # Replaces placeholder values with environment variable references.

      # Non-language-specific replacements.
      sed -i 's|https:\/\/{{< influxdb/host >}}|$INFLUX_HOST|g;
      ' $file

      # Python-specific replacements.
      # Use f-strings to identify placeholders in Python while also keeping valid syntax if
      # the user replaces the value.
      # Remember to import os for your example code.
      sed -i 's/f"ACCOUNT_ID"/os.getenv("ACCOUNT_ID")/g;
      s/f"API_TOKEN"/os.getenv("INFLUX_TOKEN")/g;
      s/f"BUCKET_NAME"/os.getenv("INFLUX_DATABASE")/g;
      s/f"CLUSTER_ID"/os.getenv("CLUSTER_ID")/g;
      s/f"DATABASE_NAME"/os.getenv("INFLUX_DATABASE")/g;
      s/f"DATABASE_TOKEN"/os.getenv("INFLUX_TOKEN")/g;
      s/f"get-started"/os.getenv("INFLUX_DATABASE")/g;
      s|f"{{< influxdb/host >}}"|os.getenv("INFLUX_HOSTNAME")|g;
      s/f"MANAGEMENT_TOKEN"/os.getenv("MANAGEMENT_TOKEN")/g;
      s|f"RETENTION_POLICY_NAME\|RETENTION_POLICY"|"autogen"|g;
      ' $file

      # Shell-specific replacements.
      ## In JSON Heredoc
      sed -i 's|"orgID": "ORG_ID"|"orgID": "$INFLUX_ORG"|g;
      s|"name": "BUCKET_NAME"|"name": "$INFLUX_DATABASE"|g;' \
      $file

      sed -i 's|"influxctl database create --retention-period 1y get-started"|"influxctl database create --retention-period 1y $INFLUX_TMP_DATABASE"|g;' \
      $file

      # Replace remaining placeholders with variables.
      # If the placeholder is inside of a Python os.getenv() function, don't replace it.
      # Note the specific use of double quotes for the os.getenv() arguments here. You'll need to use double quotes in your code samples for this to match.
      sed -i '/os.getenv("ACCOUNT_ID")/! s/ACCOUNT_ID/$ACCOUNT_ID/g;
      /os.getenv("API_TOKEN")/! s/API_TOKEN/$INFLUX_TOKEN/g;
      /os.getenv("BUCKET_ID")/! s/--bucket-id BUCKET_ID/--bucket-id $INFLUX_BUCKET_ID/g;
      /os.getenv("BUCKET_NAME")/! s/BUCKET_NAME/$INFLUX_DATABASE/g;
      /os.getenv("CLUSTER_ID")/! s/CLUSTER_ID/$CLUSTER_ID/g;
      /os.getenv("DATABASE_TOKEN")/! s/DATABASE_TOKEN/$INFLUX_TOKEN/g;
      /os.getenv("DATABASE_NAME")/! s/DATABASE_NAME/$INFLUX_DATABASE/g;
      s/--id DBRP_ID/--id $INFLUX_DBRP_ID/g;
      s/get-started/$INFLUX_DATABASE/g;
      /os.getenv("MANAGEMENT_TOKEN")/! s/MANAGEMENT_TOKEN/$MANAGEMENT_TOKEN/g;
      /os.getenv("ORG_ID")/! s/ORG_ID/$INFLUX_ORG/g;
      /os.getenv("RETENTION_POLICY")/! s/RETENTION_POLICY_NAME\|RETENTION_POLICY/$INFLUX_RETENTION_POLICY/g;
      s/CONFIG_NAME/CONFIG_$(shuf -i 0-100 -n1)/g;' \
      $file

      # v2-specific replacements.
      sed -i 's|https:\/\/us-west-2-1.aws.cloud2.influxdata.com|$INFLUX_HOST|g;
      s|{{< latest-patch >}}|${influxdb_latest_patches_v2}|g;
      s|{{< latest-patch cli=true >}}|${influxdb_latest_cli_v2}|g;' \
      $file

      # Skip package manager commands.
      sed -i 's|sudo dpkg.*$||g;
      s|sudo yum.*$||g;' \
      $file

      # Environment-specific replacements.
      sed -i 's|sudo ||g;' \
      $file
    fi
  done
}

setup() {
  # Parse YAML config files into dotenv files to be used by tests.
  parse_yaml /app/appdata/products.yml > /app/appdata/.env.products

  # Miscellaneous test setup.
  # For macOS samples.
  mkdir -p ~/Downloads && rm -rf ~/Downloads/*
}

prepare_tests() {
  TEST_FILES="$*"

  # Copy the test files to the target directory while preserving the directory structure.
  for FILE in $TEST_FILES; do
    # Create the parent directories of the destination file
    #mkdir -p "$(dirname "$TEST_TARGET/$FILE")"
    # Copy the file
    rsync -avz --relative --log-file=./test.log "$FILE" /app/
  done

  substitute_placeholders
}

# If arguments were passed and the first argument is not --files, run the command. This is useful for running "/bin/bash" for debugging the container.
# If --files is passed, prepare all remaining arguments as test files.
# Otherwise (no arguments), run the setup function and return existing files to be tested.
if [ "$1" != "--files" ]; then
  echo "Executing $0 without --files argument."
  "$@"
fi
if [ "$1" == "--files" ]; then
  shift
  prepare_tests "$@"
fi
setup
# Return new or existing files to be tested.
find "$TEST_CONTENT" -type f -name '*.md'
