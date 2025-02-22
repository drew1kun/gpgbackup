#!/usr/bin/env bash

function usage() {
    echo "DESCRIPTION:"
    echo "Generate the QR Code from Secret Key and vice versa."
    echo
    echo "DEPENDENCIES:"
    echo "  - gpg/gpg2"
    echo "  - paperkey"
    echo "  - qrencode"
    echo "  - coreutils (GNU version)"
    echo "  - pdflatex (mactex on MacOS or latex on Linux)"
    echo
    echo "On MacOS install dependencies with Homebrew:"
    echo "      'brew install gpg-suite mactex-no-gui coreutils qrencode paperkey'"
    echo
    echo "coreutils will be installed with g (for GNU) - prefix:  gsplit, ghead etc"
    echo
    echo "USAGE:"
    echo "      'gpgbackup.sh { -h | {-b | -p | -r <Key_ID>} }'"
    echo ""
    echo "      -h - Show this message."
    echo "      -b - Convert existing secret key to QR-Codes(PNG). Assumes secret key exists in gpg ring."
    echo "      -p - Generate printable pdf with QR-Codes for offline paper backup."
    echo "      -r - Convert QR-Coedes to secret key. NOTE: Public key must exist on gpg pubring."
    echo "      <Key_ID> - an email identity or the gpg key ID. Required by -b -p and -r."
    echo
    echo "EXAMPLES:"
    echo
    echo " ./gpgbackup.sh -b user@email.com  # Creates a folder with name 'user@email.com' containing tarball with 4 PNGs"
    echo "                                   # with QR-Codes for storing key backups in digital form."
    echo
    echo " ./gpgbackup.sh -p user@email.com  # Creates a folder with name 'user@email.com' containing printable PDF"
    echo "                                   # with QR-Codes for storing key backups on paper"
    echo
    echo " ./gpgbackup.sh -r user@email.com  # Recovers the secret key with 'user@email.com' ID. There must be folder"
    echo "                                   # with the same name, containing the PNGs named in order."
    echo "                                   # ORDER MATTERS! e.g.: 1.png, 2.png, 3.png, 4.png"
    echo
}
