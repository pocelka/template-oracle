#!/bin/bash

# If you need to register any aliases in bash uncomment these lines
# shopt -s expand_aliases
# This should reference where you store aliases (or manually define them)
# source ~/.aliases.sh

# Connection string to development environment
DB_NAME="CHANGE"

# SQLcl binary (either sql or sqlcl depending on if you changed anything).
# If using a docker container for SQLcl ensure the run alias does not include the "-it" option as TTY is not necessary for these scripts.
SQLCL=sql

# SQL*Plus binary.
# If using a docker container for sqlplus ensure the run alias does not include the "-it" option as TTY is not necessary for these scripts.
SQLPLUS=sqlplus

# *** VSCode Settings ***

# Compile file: chose $SQLCL or $SQLPLUS
# Recommended to use $SQLPLUS as it's quicker
VSCODE_TASK_COMPILE_BIN=$SQLCL

# This code will be run before the file is executed
read -d '' VSCODE_TASK_COMPILE_SQL_PREFIX << EOF
--
-- Add any session specific statements here. Examples:
-- alter session set plsql_ccflags = 'dev_env:true';
-- alter session set plsql_warnings = 'ENABLE:ALL';
--

set cloudconfig $OCI_WALLET

set define off
-- This will raise a warning message in SQL*Plus but worth keeping in to encourage use if using SQLcl to compile
set codescan on

EOF
