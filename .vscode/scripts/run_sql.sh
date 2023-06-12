#!/bin/bash
# Env variables $1, $2, etc. are from the tasks.json args array
# File can be referenced either as a full path or relative path
FILE_FULL_PATH=$1
BW_ENTRY=$2

# Directory of this file
TASK_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load helper
source "${TASK_SCRIPT_DIR}/../../scripts/helper.sh"

# Determine platform to correctly set OCI wallet.
if [ "$(uname)" == "Darwin" ]; then
  OCI_WALLET=${OCI_WALLET_MAC}
else
  OCI_WALLET="${OCI_WALLET_LINUX}"
fi

echo -e "Parsing file: ${COLOR_LIGHT_GREEN}$FILE_FULL_PATH${COLOR_RESET}"

# Run sqlplus/sqlcl, execute the script, then get the error list and exit
$SQL_CLI_BINARY /nolog << EOF

-- User specific commands:
--------------------------------------------------------------------------------
set cloudconfig $OCI_WALLET

set define off
-- This will raise a warning message in SQL*Plus but worth keeping in to encourage use if using SQLcl to compile
set codescan on
--------------------------------------------------------------------------------


-- Connect to DB
connect ${DB_USER}/${DB_PASSWORD}@${DB_NAME}

-- Run file
@${FILE_FULL_PATH}

set define on
-- show errors
@${SCRIPTS_DIR}/show_errors.sql
exit;
EOF
