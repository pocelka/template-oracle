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

get_connection_string() {

  BW=$(bw get item "${BW_ENTRY}")

  DB_USER=$(echo "${BW}" | jq -r '.login.username')
  DB_PASSWORD=$(echo "${BW}" | jq -r '.fields[] | select (.name=="DB Pass") | .value')
  DB_NAME=$(echo "${BW}" | jq -r '.fields[] | select (.name=="TNS") | .value')
  APEX_WS=$(echo "${BW}" | jq -r '.fields[] | select (.name=="Workspace") | .value')

}
################################################################################

load_colors
get_connection_string
