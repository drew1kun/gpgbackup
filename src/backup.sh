#!/usr/bin/env bash

function backup() {
    if [[ $# -ne 4 ]]; then
        echo "Usage: backup <KEYID> <SPLIT> <SECRM> <GPG>"
        exit 1
    fi

    local KEYID="$1"
    local SPLIT="$2"
    local SECRM="$3"
    local GPG="$4"

    local DIR="${KEYID}.qr.png"

    echo "Creating QR PNG images for ${KEYID}"

    mkdir -p "${DIR}"
    pushd "${DIR}" > /dev/null || exit 1  # Instead of cd "${DIR}"

    "${GPG}" --export-secret-key "${KEYID}" | paperkey --output-type raw | base64 > "${KEYID}".asc
    "${SPLIT}" -n 4 --numeric-suffixes=1 -d "${KEYID}.asc" "part-"
    for f in part-*; do cat ${f} | qrencode -o "${KEYID}.${f}.png"; done

    # Archive the QR images:
    echo "Archiving:"
    tar -cvzf "${KEYID}.qr.tar.gz" *.png

    # Cleanup:
    find . -type f -name "*" ! -name "${KEYID}.qr.tar.gz" -exec $SECRM {} +  > /dev/null 2>&1

    popd > /dev/null || exit 1  # Moving back after pushd
    echo
    echo "The archive with QR PNGs was generated!"
    echo
    echo "check ${KEYID}.qr.png directory"
    exit 0
}
