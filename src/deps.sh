#!/usr/bin/env bash

function check_deps() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "gpg/gpg2 is not installed. Aborting."; exit 1; }
    command -v paperkey >/dev/null 2>&1 || { echo >&2 "paperkey is not installed. Aborting."; exit 1; }
    command -v qrencode >/dev/null 2>&1 || { echo >&2 "qrencode is not installed. Aborting."; exit 1; }
    command -v zbarimg >/dev/null 2>&1 || { echo >&2 "zbarimg (zbar) is not installed. Aborting."; exit 1; }
    command -v pdflatex >/dev/null 2>&1 || { echo >&2 "pdflatex is not installed. Aborting."; exit 1; }
    command -v shred >/dev/null 2>&1 || { echo >&2 "shred is not installed. Aborting."; exit 1; }
    command -v "${SPLIT}" >/dev/null 2>&1 || { echo >&2 "${SPLIT} is not installed. Aborting."; exit 1; }
}
