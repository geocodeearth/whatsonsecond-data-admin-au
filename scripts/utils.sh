#!/bin/bash
set -euo pipefail

# OSX comes bundled with versions of readlink, sed, parallel etc which are not
# compatible with the linux tools. Force OSX users to install the GNU
# compatible versions (prefixed with 'g', such as 'greadlink', 'gsed' etc.).
export CMD_READLINK='readlink'
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [ -x "$(command -v greadlink)" ]; then
    CMD_READLINK='greadlink';
  else
    2>&1 echo 'OSX: you must install the gnu standard tooling using:'
    2>&1 echo 'brew install coreutils'
  fi
fi

# resolve paths
export SCRIPTS_DIR=$( dirname $( ${CMD_READLINK} -f "${BASH_SOURCE[0]}" ) )
export DOWNLOADS_DIR="${SCRIPTS_DIR}/../downloads"
export CONCORDANCES_DIR="${SCRIPTS_DIR}/../concordances"
export DATA_DIR="${SCRIPTS_DIR}/../data"
