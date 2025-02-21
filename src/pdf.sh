#!/usr/bin/env bash -x

function pdf() {
    if [[ $# -ne 6 ]]; then
        echo "Usage: pdf <KEYID> <HEAD> <DECODE> <SPLIT> <SECRM> <GPG>"
        exit 1
    fi

    read -sp "Enter your key passphrase (will be shown on PDF): " SECRET

    local KEYID="$1"
    local HEAD="$2"
    local DECODE="$3"
    local SPLIT="$4"
    local SECRM="$5"
    local GPG="$6"

    echo
    echo "Generating PDF with QRs for ${KEYID}"

    # Ensure the output directory exists
    mkdir -p "./${KEYID}.qr.pdf"
    pushd "./${KEYID}.qr.pdf" > /dev/null || exit 1  # Instead of cd..

    # Prepare LaTeX document with variables from the template:
    sed -e "s|KEYID|${KEYID}|g" \
        -e "s|HEAD|${HEAD}|g" \
        -e "s|DECODE|${DECODE}|g" \
        -e "s|SPLIT|${SPLIT}|g" \
        -e "s|SECRM|${SECRM}|g" \
        -e "s|GPG|${GPG}|g" \
        -e "s|SECRET|${SECRET}|g" \
        ../latex/gpgpaper.template.tex > "${KEYID}.tex"

    # GENERATE THE PDF
    # Run pdflatex twice to resolve references, including lastPage
    for i in {1..2}; do
        if pdflatex --shell-escape "${KEYID}.tex" > /dev/null 2>&1; then
            echo "Pass ${i} successful."
        else
            echo "Error: Pass ${i} failed."
            exit 1
        fi
    done

    # CLEANUP:
    find . -type f -name "${KEYID}.*" ! -name "${KEYID}.pdf" -exec ${SECRM} {} +  > /dev/null 2>&1
    echo "Cleanup complete."

    popd > /dev/null || exit 1  # Moving back after pushd
    echo "PDF was generated, check ${KEYID}.qr.pdf directory"
    exit 0
}
