#!/usr/bin/env zsh

set -e  # Exit immediately if a command exits with a non-zero status
set -x  # Print commands and their arguments as they are executed

# Source the .env file
if ! source .env; then
  echo "Error: Could not source .env"
  exit 1
fi

LOGFILE="$LOGFILE_PATH"
PROJECT_DIR="$PROJECT_PATH"

export PATH="/opt/homebrew/bin:$PATH"  # Or your npm path

# Change to the project directory
cd "$PROJECT_DIR" || exit 1

TEMP_OUTPUT=$(mktemp)

function cleanup() {
  echo "{\"time\":\"$(date +'%Y-%m-%dT%H:%M:%S%z')\",\"event\":\"shutdown\"}" >> "$LOGFILE"
  kill $PID 2>/dev/null
  rm -f "$TEMP_OUTPUT"
  exit 0
}

trap cleanup EXIT INT TERM

echo "{\"time\":\"$(date +'%Y-%m-%dT%H:%M:%S%z')\",\"event\":\"startup\"}" >> "$LOGFILE"

# Run the command in the background and redirect its output to a temporary file
eval "$COMMAND" > "$TEMP_OUTPUT" 2>&1 &
PID=$!
sleep 2  # Give the command time to start producing output

# Create the log file if it doesn't exist
touch "$LOGFILE"

# Process output from the temporary file
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$line" ]]; then
    continue
  fi

  # Check if line starts with something like [INFO] or [SUCCESS]
  if [[ "$line" =~ '\[([A-Za-z0-9_-]+)\][[:space:]]+(.*)' ]]; then
    rawLevel="${match[1]}"
    cleanMsg="${match[2]}"
  else
    rawLevel="LOG"
    cleanMsg="$line"
  fi

  # Map certain levels to something else
  case "$rawLevel" in
    SUCCESS|webpackbar|LOG)
      logLevel="INFO"
    ;;
    ERROR|ERR)
      logLevel="ERROR"
    ;;
    WARN|WARNING)
      logLevel="WARN"
    ;;
    *)
      logLevel="$rawLevel"
    ;;
  esac

  # Escape quotes
  safeMsg=$(echo "$cleanMsg" | sed 's/"/\\"/g')

  # Build JSON line (compact spacing)
  echo "{\"time\":\"$(date +'%Y-%m-%dT%H:%M:%S%z')\",\"event\":\"log\",\"level\":\"$logLevel\",\"message\":\"$safeMsg\"}" >> "$LOGFILE"

done < <(tail -f "$TEMP_OUTPUT")

wait $PID

set +x  # Turn off debugging
