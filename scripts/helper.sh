#!/bin/bash

# Global variables
# Find the current path this script is in
# This needs to be run outside of any functions as $0 has different meaning in a function
# If this script is being called from using "source ..." then ${BASH_SOURCE[0]} evaluates to null Use $0 instead
if [ -z "${BASH_SOURCE[0]}" ] ; then
  SCRIPTS_DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
else
  SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

# Root folder in project directory
PROJECT_DIR="$(dirname "$SCRIPTS_DIR")"


# Load colors
# To use colors:
# echo -e "${COLOR_RED}this is red${COLOR_RESET}"
load_colors(){
  # Colors for bash. See: http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
  COLOR_LIGHT_GREEN='\033[0;92m'
  COLOR_ORANGE='\033[0;33m'
  COLOR_RED='\033[0;31m'
  COLOR_RESET='\033[0m' # No Color

  FONT_BOLD='\033[1m'
  FONT_RESET='\033[22m'
}
################################################################################

# Load the config file stored in scripts/config
load_config(){
  USER_CONFIG_FILE=$PROJECT_DIR/scripts/config_user.sh
  PROJECT_CONFIG_FILE=$PROJECT_DIR/scripts/config_project.sh

  if [[ ! -f $USER_CONFIG_FILE ]] ; then
    echo -e "${COLOR_RED}Warning: database connection configuration is missing ${COLOR_RESET}"
    echo -e "${FONT_BOLD}Modify $USER_CONFIG_FILE${FONT_RESET} with your DB connection string and APEX applications."
    exit
  fi

  # Load project config
  source $PROJECT_CONFIG_FILE
  # Load user config
  source $USER_CONFIG_FILE
}
################################################################################

verify_config() {
  # SCHEMA_NAME is required
  if [[ $SCHEMA_NAME = "CHANGEME" ]] || [[ -z "$SCHEMA_NAME" ]]; then
    echo -e "${COLOR_RED}SCHEMA_NAME is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi

  # APEX_APP_IDS should be blank or list of IDs and not what is provided by default
  if [[ $APEX_APP_IDS = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_APP_IDS is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi

  # APEX_WORKSPACE should be blank or list of IDs and not what is provided by default
  if [[ $APEX_WORKSPACE = "CHANGEME" ]]; then
    echo -e "${COLOR_RED}APEX_WORKSPACE is not configured.${COLOR_RESET} Modify $PROJECT_CONFIG_FILE"
    exit
  fi

  # Check that DB connection string is defined
  if [[ $DB_CONN == *"CHANGME_USERNAME"* ]]; then
    echo -e "${COLOR_RED}DB_CONN is not configured.${COLOR_RESET} Modify $USER_CONFIG_FILE"
    exit
  fi
}
################################################################################

get_connection_string() {

  DB_USER=$(bw get item "${BW_ENTRY}" | jq -r '.login.username')
  DB_PASSWORD=$(bw get item "${BW_ENTRY}" | jq -r '.fields[] | select (.name=="DB Pass") | .value')

}
################################################################################

load_colors
load_config
#  verify_config
get_connection_string
