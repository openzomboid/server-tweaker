#!/usr/bin/env bash

VERSION="$1"
if [ -z "${VERSION}" ]; then echo "VERSION is not set. Use ./release.sh 0.0.0 stage" >&2; exit 1; fi

STAGE="$2"
if [ -z "${STAGE}" ]; then STAGE="prod"; fi

MOD_NAME="ServerTweaker"
if [ "${STAGE}" == "test" ]; then MOD_NAME="${MOD_NAME}Test"; fi
if [ "${STAGE}" == "local" ]; then MOD_NAME="${MOD_NAME}Local"; fi

RELEASE_NAME="${MOD_NAME}-${VERSION}"

rm -r .tmp/release
mkdir -p .tmp/release
touch .tmp/release/checksum.txt

function make_release() {
    local dir_workshop=".tmp/release/${RELEASE_NAME}"
    local dir="${dir_workshop}/Contents/mods/${MOD_NAME}"

    mkdir -p "${dir}"

    case $STAGE in
        local)
            cp workshop/local/workshop.txt "${dir_workshop}"
            cp workshop/local/mod.info "${dir}"
            ;;
        test)
            cp workshop/test/workshop.txt "${dir_workshop}"
            cp workshop/test/mod.info "${dir}"
            ;;
        prod)
            cp workshop/workshop.txt "${dir_workshop}"
            cp workshop/mod.info "${dir}"
            ;;
        *)
            echo "incorrect stage" >&2
            exit 1
            ;;
    esac

    cp workshop/poster.png "${dir_workshop}/preview.png"
    cp workshop/poster.png "${dir}"
    cp src -r "${dir}/media"

    find "${dir}/media" -name '*_test.lua' -type f -delete

    cp LICENSE "${dir}"
    cp README.md "${dir}"
    cp CHANGELOG.md "${dir}"

    cd "${dir_workshop}/Contents/mods/"
    tar -zcvf "../../../${RELEASE_NAME}.tar.gz" "${MOD_NAME}"
    zip -r "../../../${RELEASE_NAME}.zip" "${MOD_NAME}"

    cd ../../../ && {
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

make_release && install_release
