#!/usr/bin/env bash
# Importing the QR codes:
# Note that, when making scans or photographs, you do not produce large images.
# If zbar does not recognise your QR code, try downscaling the image.

#========== Define functions ===========
function usage {
    echo "Generate the QR Code from Secret Key and vice versa."
    echo ""
    echo "The script will create a directory with <Key_ID> name,"
    echo "containing a tarball with 4 PNG QR-Code files for specified secret key."
    echo ""
    echo "Depends on:"
    echo "  - gpg/gpg2"
    echo "  - paperkey"
    echo "  - qrencode"
    echo "  - coreutils (GNU version)"
    echo "  - pdflatex (mactex on MacOS or latex on Linux)"
    echo ""
    echo "MacOS: install dependencies with Homebrew:"
    echo ""
    echo "      'brew cask install gpg-suite mactex'"
    echo "Install GPGTools GUI with gpg/gpg CLI as well as mactex(pdflatex)"
    echo ""
    echo "      'brew install coreutils qrencode paperkey ghostscript'"
    echo "coreutils will be installed with g (for GNU) - prefix:  gsplit, ghead etc"
    echo ""
    echo "Usage: "
    echo "      'gpg2qr.sh { -h | {-k | -q <Key_ID>} }'"
    echo ""
    echo "      -h, ?, --help - This message"
    echo "      -k, --key2qr - Convert existing secret key to QR-Codes(PNG). Assumes secret key exists in gpg ring"
    echo "      -q, --qr2key - Convert QR-Coedes to secret key. NOTE: Public key must exist on gpg pubring"
    echo "      <Key_ID> - an email identity or the gpg key ID"
    echo ""
}

function check_deps {
    command -v gpg >/dev/null 2>&1 || { echo >&2 "gpg/gpg2 is not installed.  Aborting."; exit 1; }
    command -v paperkey >/dev/null 2>&1 || { echo >&2 "paperkey is not installed.  Aborting."; exit 1; }
    command -v qrencode >/dev/null 2>&1 || { echo >&2 "qrencode is not installed.  Aborting."; exit 1; }
    command -v zbarimg >/dev/null 2>&1 || { echo >&2 "zbarimg (zbar) is not installed.  Aborting."; exit 1; }
    command -v pdflatex >/dev/null 2>&1 || { echo >&2 "pdflatex is not installed.  Aborting."; exit 1; }
}

function key2qr {
    mkdir -p ./$1
    gpg2 --export-secret-key $1 | paperkey --output-type raw | base64 > $1.ascii
    $2 -n 4 -d $1.ascii qr_
    for f in qr_*; do cat ${f} | qrencode -o $1_${f}.png; done
    tar -cvzf $1.qr.tar.gz ./*qr_*.png
    mv $1.qr.tar.gz ./$1

    # Cleanup
    rm -fP $1.ascii *qr_*
    exit 0
}

function genpdf {
    mkdir -p ./$1

    # prepare gpgbackup.tex self generated latex document:
    cat ./latex/gpgbackup.tex.template | sed -e "s/PRIVATE_KEY/$1/g" \
    -e "s/HEAD/$2/g" \
    -e "s/DECODE/$3/g" \
    -e "s/SPLIT/$4/g" > gpgbackup.tex

    # generate pdf and move it right place:
    pdflatex --shell-escape gpgbackup.tex > /dev/null 2>&1
    mv gpgbackup.pdf ./$1

    # Cleanup:
    rm -fP gpgbackup.log gpgbackup.tex gpgbackup.aux
    exit 0
}

function qr2key {
    cd ./$1
    for f in *.png; do zbarimg --raw $f | $2 -c -1 > $f.out.ascii ; done
    cat *.out.ascii | base64 $3 | paperkey --pubring ~/.gnupg/pubring.gpg > "$1.asc"
    #cat *.out.ascii | base64 $3 | paperkey --pubring ~/.gnupg/pubring.gpg | gpg2 --import

    # Cleanup
    rm -fP *.out.ascii
    exit 0
}

#=======================================

#================ Main =================
PRIVATE_KEY=$2

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
        echo "Unknown OS, Only MacOS and Linux supported for now"
esac

check_deps

# All of these commands are mutually exclusive, so we test for a single param here:
if [[ $# -lt 1 ]]; then
    echo "Please choose AT LEAST ONE option -k | -p | -q. See gpg2qr.sh -h"
    exit 1
elif [[ $# -gt 2 ]]; then
    echo "Please choose ONLY ONE option: -k | -p | -q option. See gpg2qr.sh -h"
    exit 1
fi

# Parse Arguments
while getopts ':hk:p:q:' opt; do
    case ${opt} in
        k)
            key2qr "${PRIVATE_KEY}" "${SPLIT}"
            ;;
        q)
            qr2key "${PRIVATE_KEY}" "${HEAD}" "${DECODE}"
            ;;
        p)
            genpdf "${PRIVATE_KEY}" "${HEAD}" "${DECODE}" "${SPLIT}"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option -${OPTARG}. Try 'gpg2qr.sh -h' first"
            exit 0
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            exit 1
            ;;
    esac
done
#=======================================
