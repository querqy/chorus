#!/bin/bash

# This is because true is usually 1 in most programming contexts, however in linux and bash
# 0 usually means "success", so let's just be clear.
TRUE=1
FALSE=0

# Ansi color code variables
PROGRAM_NAME="QUICKSTART"
ERROR='\033[0;31m['$PROGRAM_NAME'] '
BLUE='\033[0;34m['$PROGRAM_NAME'] '
LIGHT_GRAY='\033[0;37m['$PROGRAM_NAME']    '
RESET='\033[0m' # No Color
BOLD_GREEN='\033[1;32m['$PROGRAM_NAME'] '
BOLD_RED='\033[1;31m['$PROGRAM_NAME'] '

function prerequisite_is_available() {
    COMMAND="command -v $1"
    if [ -x "$($COMMAND)" ]; then
        return $TRUE
    else
        return $FALSE
    fi
}

function log_major() {
    echo -e "${BLUE}$1${RESET}"
}

function log_minor() {
    echo -e "${LIGHT_GRAY}$1${RESET}"
}

function log_awesome() {
    echo
    echo -e "${RESET}${BOLD_GREEN}$1${RESET}"
    echo
}

function log_green() {
    echo -e "${BOLD_GREEN}$1${RESET}"
}

function log_red() {
    echo -e "${BOLD_RED}$1${RESET}"
    exit 1
}

function log_prerequisite_found() {
    #printf "${BOLD_GREEN}%23s %s ${RESET}\n" "$1 [FOUND]"
    echo -e "${BOLD_GREEN}Found prerequisite   : $1${RESET}"
}

function log_prerequisite_missing() {
    #printf "${BOLD_RED}%25s %s ${RESET}\n" "$1 [MISSING]"
    echo -e "${BOLD_RED}Missing prerequisite : $1${RESET}"
}

function check_prerequisites() {
    set +e
    PREREQUISITES=("curl" "jq" "docker-compose" "zip")
    log_major "Checking availability of prerequisites..."
    COUNT_MISSING_PREQUISITES=0
    for PREREQUISITE in "${PREREQUISITES[@]}"
    do
        prerequisite_is_available "${PREREQUISITE}"
        PREREQ_AVAILABLE=$?
        if [ $PREREQ_AVAILABLE = $TRUE ]; then
            #log_prerequisite_found $PREREQUISITE
        else
            log_prerequisite_missing "${PREREQUISITE}"
            COUNT_MISSING_PREQUISITES=$((COUNT_MISSING_PREQUISITES+1))
        fi
    done

    if [[ $COUNT_MISSING_PREQUISITES = 0 ]]; then
        log_green "All prerequisites were found."
        set -e
    else
        log_red "Install missing prerequisites and try again."
        exit 1
    fi
}

function display_help_message() {
    echo -e "Use the option --with-offline-lab | -lab to include Quepid and RRE services in Chorus."
    echo -e "Use the option --with-observability | -obs to include Grafana, Prometheus, and Solr Exporter services in Chorus."
    echo -e "Use the option --with-vector-search | -vector to include Vector Search services in Chorus."
    echo -e "Use the option --with-active-search-management | -active to include Active Search Management in Chorus."
    echo -e "Use the option --shutdown | -s to shutdown and remove the Docker containers and data."
    echo -e "Use the option --online-deployment | -online to update configuration to run on chorus.dev.o19s.com environment."
}
