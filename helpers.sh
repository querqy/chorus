#!/bin/bash

# Ansi color code variables
ERROR='\033[0;31m[QUICKSTART] '
MAJOR='\033[0;34m[QUICKSTART] '
MINOR='\033[0;37m[QUICKSTART]    '
AWESOME='\033[1;32m[QUICKSTART] '
RESET='\033[0m' # No Color

function log_reset() {
  echo -e "${RESET}"
  echo
}

function log_awesome() {
  echo -e "${AWESOME}$1${RESET}"
}

function log_major() {
  echo -e "${MAJOR}$1${RESET}"
}

function log_minor() {
  echo -e "${MINOR}$1${RESET}"
}

function log_error() {
  echo -e "${ERROR}Error: $1${RESET}" >&2
}

function retry_until_command_success_and_responseHeader_status_is_zero() {
  set +e
  INNER_RESULT="none"
  FINAL_ANALYSIS="unknown"
  SUCCESS=0
  RESULT=1
  SECONDS_TO_PAUSE_BEFORE_RETRY=0
  while [[ $RESULT -ne $SUCCESS ]]; do 
    # echo "looping@"$SECONDS_TO_PAUSE_BEFORE_RETRY
    # echo "command: "$@
    sleep $SECONDS_TO_PAUSE_BEFORE_RETRY
    # Run the command that was passed into the function
    OUTPUT=$(eval $@)
    # What was the result of the eval command? 0 means success and 1 means failure
    RESULT=$?
    if [[ $RESULT -eq $SUCCESS ]]; then
        JQ="echo '${OUTPUT}' | jq .responseHeader.status"
        # echo $JQ
        INNER_OUTPUT=$(eval $JQ)
        INNER_RESULT=$?
        if [[ $INNER_RESULT -eq 0  ]]; then
            if [ "${INNER_OUTPUT}" = "0" ]; then
                # echo "inner output means success"
                FINAL_ANALYSIS="success"
            else
                # echo "inner output means failure"
                FINAL_ANALYSIS="failure"
                RESULT=1
            fi
        else
            FINAL_ANALYSIS="failure"
            RESULT=1
        fi
    else
        # echo "command failed"
        :
    fi
    ((SECONDS_TO_PAUSE_BEFORE_RETRY=SECONDS_TO_PAUSE_BEFORE_RETRY+1))
  done
  # echo "The final result was: ${FINAL_ANALYSIS}"
  set -e
}