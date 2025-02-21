#!/usr/bin/env bash

function restore() {
    if [[ $# -ne 5 ]]; then
        echo "Usage: restore <KEYID> <HEAD> <DECODE> <SECRM> <GPG>"
        exit 1
    fi

    local KEYID="$1"
    local HEAD="$2"
    local DECODE="$3"
    local SECRM="$4"
    local GPG="$5"

    echo "Fetching the public key for ${KEYID} from keys.openpgp.org"
    "${GPG}" --keyserver hkps://keys.openpgp.org --recv-keys "${KEYID}"

    echo "Restoring ${KEYID} from QRs"
    pushd ./${KEYID}.qr         # Instead of cd ./${KEYID}.qr
    "${GPG}" --export "${KEYID}" > public.gpg
    for f in *.png; do zbarimg --raw "${f}" | ${HEAD} -c -1 > "${f}".out.asc ; done
    cat *.out.asc | base64 "${DECODE}" | paperkey --pubring public.gpg | "${GPG}" --import

    # CLEANUP:
    ${SECRM} *.out.asc public.gpg > /dev/null 2>&1

    popd > /dev/null || exit 1  # Moving back after pushd
    echo "Restore complete."
    exit 0
}
