#!/bin/bash
# Env variables $1, $2, etc are from the tasks.json args array
BW_ENTRY=$1
APEX_APP_ID=$2

# Directory of this file
TASK_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load helper
source "${TASK_SCRIPT_DIR}/../../scripts/helper.sh"

if [ "${APEX_APP_ID}" == "" ]; then
  echo -e "${COLOR_RED}Appex application ID was not specified.${COLOR_RESET}"
  exit
fi

# Determine platform to correctly set OCI wallet.
if [ "$(uname)" == "Darwin" ]; then
  OCI_WALLET="${OCI_WALLET_MAC}"
else
  OCI_WALLET="${OCI_WALLET_LINUX}"
fi

# I want to remove old epxports to ensure that if some files are obsolete, they are no longer in the repository.
rm -rf "${PROJECT_DIR}/database/apex/"
mkdir -p "${PROJECT_DIR}/database/apex"

for app in $(echo "${APEX_APP_ID}" | tr ',' '\n')
do

  echo -e "${COLOR_ORANGE}Exporting application ID: ${app}.${COLOR_RESET}"

  # Export application
  $SQL_CLI_BINARY /nolog << EOF

  -- User specific commands:
  --------------------------------------------------------------------------------
  set cloudconfig $OCI_WALLET
  --------------------------------------------------------------------------------

  -- Connect to DB
  connect ${DB_USER}/${DB_PASSWORD}@${DB_NAME}

  --export in split format
  apex export -applicationid ${app} -dir ${PROJECT_DIR}/database/apex -skipExportDate -expPubReports -expSavedReports -expTranslations -split

  --export in full format
  apex export -applicationid ${app} -dir ${PROJECT_DIR}/database/apex -skipExportDate -expPubReports -expSavedReports -expTranslations

  exit;
EOF

  VERSION=$(head -n 1 "${PROJECT_DIR}/version")

  # In order to support the various versions of sed need to add the "-bak"
  # See: https://unix.stackexchange.com/questions/13711/differences-between-sed-on-mac-osx-and-other-standard-sed/131940#131940
  if [ "${VERSION}" != "" ]; then
    sed --in-place=-bak "s/%RELEASE_VERSION%/$VERSION/" "${PROJECT_DIR}/database/apex/f${app}.sql"
    sed --in-place=-bak "s/%RELEASE_VERSION%/$VERSION/" "${PROJECT_DIR}/database/apex/f${app}/application/create_application.sql"

    # Remove the backup version of file (see above)
    rm "${PROJECT_DIR}/database/apex/f${app}.sql-bak"
    rm "${PROJECT_DIR}/database/apex/f${app}/application/create_application.sql-bak"

  fi

done
