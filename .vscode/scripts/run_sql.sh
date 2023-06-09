#!/bin/bash
# Env variables $1, $2, etc. are from the tasks.json args array

# Directory of this file
TASK_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# File can be referenced either as a full path or relative path
FILE_RELATIVE_PATH=$1
FILE_FULL_PATH=$2
BW_ENTRY=$3

# Load helper
source "${TASK_SCRIPT_DIR}/../../scripts/helper.sh"

echo -e "Parsing file: ${COLOR_LIGHT_GREEN}$FILE_FULL_PATH${COLOR_RESET}"

# run sqlplus/sqlcl, execute the script, then get the error list and exit
# VSCODE_TASK_COMPILE_BIN is set in the config_user.sh file (either sqlplus or sqlcl)
$VSCODE_TASK_COMPILE_BIN /nolog << EOF

-- Load user specific commands here
$VSCODE_TASK_COMPILE_SQL_PREFIX

-- Connect to DB
connect ${DB_USER}/${DB_PASSWORD}@${DB_NAME}

-- Run file
@${FILE_FULL_PATH}

set define on
-- show errors
@${SCRIPTS_DIR}/show_errors.sql
exit;
EOF
