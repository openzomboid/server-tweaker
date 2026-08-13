#!/usr/bin/env bash

VERSION="$1"
if [ -z "${VERSION}" ]; then echo "VERSION is not set. Use ./release.sh 0.0.0 stage" >&2; exit 1; fi

STAGE="$2"
if [ -z "${STAGE}" ]; then STAGE="prod"; fi

MOD_NAME="ServerTweaker"
if [ "${STAGE}" == "test" ]; then MOD_NAME="${MOD_NAME}Test"; fi
if [ "${STAGE}" == "local" ]; then MOD_NAME="${MOD_NAME}Local"; fi

RELEASE_NAME="${MOD_NAME}-${VERSION}"

RELEASE_DIR_WORKSHOP=".tmp/release/${RELEASE_NAME}"
RELEASE_DIR_MOD_HOME="${RELEASE_DIR_WORKSHOP}/Contents/mods/${MOD_NAME}"

rm -r .tmp/release
mkdir -p .tmp/release
touch .tmp/release/checksum.txt

function make_release() {
  local dir_workshop=${RELEASE_DIR_WORKSHOP}
  local dir_mod_home="${RELEASE_DIR_MOD_HOME}"

  local dir_common="${dir_mod_home}/common"
  local dir_42="${dir_mod_home}/42"

  mkdir -p "${dir_mod_home}"
  mkdir -p "${dir_common}"
  mkdir -p "${dir_42}"

  case $STAGE in
    local|test|prod)
      cp workshop/${STAGE}/workshop.txt "${dir_workshop}"
      cp workshop/${STAGE}/mod.info "${dir_42}"
      ;;
    *)
      echo "incorrect stage" >&2
      exit 1
      ;;
  esac

  sed -i -r "s/id=${MOD_NAME}/id=${MOD_NAME}/g" "${dir_42}/mod.info"

  cp workshop/preview.png "${dir_workshop}/preview.png"
  cp workshop/poster.png "${dir_42}"
  cp src/b42 -r "${dir_42}/media"

  find "${dir_42}/media" -name '*_test.lua' -type f -delete

  cp LICENSE "${dir_42}"
  cp README.md "${dir_42}"
  cp CHANGELOG.md "${dir_42}"
  cp VERSION "${dir_42}"
}

function compress_release() {
  local dir_workshop=${RELEASE_DIR_WORKSHOP}

  cd "${dir_workshop}/Contents/mods/" && {
    tar -zcvf "../../../${RELEASE_NAME}.tar.gz" "${MOD_NAME}"
    zip -r "../../../${RELEASE_NAME}.zip" "${MOD_NAME}"
  }

  cd ../../../ && {
    md5sum "${RELEASE_NAME}_b41.tar.gz" >> checksum.txt;
    md5sum "${RELEASE_NAME}_b41.zip" >> checksum.txt;

    md5sum "${RELEASE_NAME}.tar.gz" >> checksum.txt;
    md5sum "${RELEASE_NAME}.zip" >> checksum.txt;
    cd ../../;
  }
}

function install_release() {
  rm -r ~/Zomboid/Workshop/"${MOD_NAME}"
  cp -r  .tmp/release/"${RELEASE_NAME}" ~/Zomboid/Workshop/"${MOD_NAME}"
  rm -r .tmp/release/"${RELEASE_NAME}"
}

make_release && compress_release && install_release
