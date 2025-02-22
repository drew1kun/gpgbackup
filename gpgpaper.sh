#!/usr/bin/env bash
# Importing the QR codes:
# Note that, when making scans or photographs, you do not produce large images.
# If zbar does not recognise your QR code, try downscaling the image.

for file in ./src/*.sh; do
    source "${file}"
done

KEYID=$2
SECRM='shred -vuzn 4'
GPG='gpg'

# Detect OS
OS="$(uname | tr '[:upper:]' '[:lower:]')"

case ${OS} in
    'darwin')
        HEAD='ghead'
        DECODE='-D'
        SPLIT='gsplit'
        ;;
    'linux')
        HEAD='head'
        DECODE='-d'
        SPLIT='split'
        ;;
    *)
        echo "Unknown OS. Only MacOS and Linux are supported at the moment."
esac

check_deps "${GPG}"

# All of these commands are mutually exclusive, so we test for a single param here:
if [[ $# -lt 1 ]]; then
    echo "Please choose AT LEAST ONE option -b | -p | -r. See gpgpaper.sh -h"
    exit 1
elif [[ $# -gt 2 ]]; then
    echo "Please choose ONLY ONE option: -b | -p | -r option. See gpgpaper.sh -h"
    exit 1
fi

# Parse Arguments
while getopts ':hb:p:r:' opt; do
    case ${opt} in
        b)
            backup "${KEYID}" "${SPLIT}" "${SECRM}" "${GPG}"
            ;;
        r)
            restore "${KEYID}" "${HEAD}" "${DECODE}" "${SECRM}" "${GPG}"
            ;;
        p)
            pdf "${KEYID}" "${HEAD}" "${DECODE}" "${SPLIT}" "${SECRM}" "${GPG}"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option -${OPTARG}. Try 'gpgpaper.sh -h' first"
            exit 0
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            exit 1
            ;;
    esac
done
