#!/usr/bin/env bash

# BASEDIR contains tests.sh script directory name.
# If system does not have readlink this test can not be
# executed via a symbolic link in a different directory.
BASEDIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
if [ "${BASEDIR}" == "." ]; then
    BASEDIR=$(dirname "$BASH_SOURCE")
fi

# DIR_TESTS contains directory name with test files.
DIR_TESTS="${BASEDIR}/tests"

FAIL=$(echo -e "[\033[0;31m fail \033[0m]")

# Import from local config file if exists.
FILE_CONFIG_LOCAL="${DIR_TESTS}/config-local.sh"
# shellcheck source=tests/config-local.sh
test -f "${FILE_CONFIG_LOCAL}" && . "${FILE_CONFIG_LOCAL}"

# PZ_PATH contains Project Zomboid installed files. This path is needed for
# mocks Project Zomboid server. Can be defined in env before running tests.sh script.
# If not defined try to import from local config or find on disk.
# Mostly located in ~/.local/share/Steam/steamapps/common/ProjectZomboid/projectzomboid.
if [ -z "${PZ_PATH}" ]; then
  echo -e "[ info ] PZ_PATH is not defined. Find Project Zomboid files..."

  search_label="/media/lua/shared/luautils.lua"

  # Exclude directories from search where Project Zomboid cannot be installed.
  excluded=(/proc /tmp /dev /sys /snap /etc /var /run /snap /boot)
  for ex in "${excluded[@]}"; do
    excluded_args="${excluded_args} -path ${ex} -prune -o"
  done

  # WARNING: don't quote excluded_args!
  PZ_PATH=$(find / ${excluded_args} -path "*${search_label}" -print -quit 2> /dev/null | sed "s#${search_label}##g")

  if [ -z "${PZ_PATH}" ]; then
    echo -e "$FAIL Cannot find installed Project Zomboid for getting needed lua files." >&2
    echo -e "[ info ] Please define PZ_PATH env with path to Prozect Zomboid before executing test script." >&2
    echo -e "[ info ] Or place MEDIA_LUA_PATH declaration to the configuration file" >&2
    echo -e "[ info ] ${FILE_CONFIG_LOCAL}" >&2

    exit 1
  fi

  echo -e "[ info ] PZ_PATH=${PZ_PATH}"
  echo -e ""
fi

if [ -z "${TESTDATA_PATH}" ]; then
  TESTDATA_PATH="${DIR_TESTS}/testdata"
fi

# Run lua tests.
while [[ -n "$1" ]]; do
  case "$1" in
    shared)
      cd "${DIR_TESTS}" && echo "Starting shared tests..." \
        && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$2 lua ./shared.lua
      exit ;;
    server)
      cd "${DIR_TESTS}" && echo "Starting server tests..." \
        && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$2 lua ./server.lua
      exit ;;
    client)
      cd "${DIR_TESTS}" && echo "Starting client tests..." \
        && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$2 lua ./client.lua
      exit ;;
    *)
      echo "$FAIL $1 is not an option" >&2
      exit ;;
  esac

  shift
done

# FIXME: Fix "is not an option" error
cd "${DIR_TESTS}" \
  && echo "Starting shared tests..." \
  && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$1 lua ./shared.lua \
  && echo \
  && echo "Starting server tests..." \
  && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$1 lua ./server.lua \
  && echo \
  && echo "Starting client tests..." \
  && PZ_PATH=${PZ_PATH} TESTDATA_PATH=${TESTDATA_PATH} TEST_PATTERN=$1 lua ./client.lua
