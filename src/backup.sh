#!/usr/bin/env bash

function backup() {
    echo "Creating QR images for $1"
    mkdir -p ./$1.qr.png
    cd ./$1.qr.png
    $4 --export-secret-key $1 | paperkey --output-type raw | base64 > $1.asc
    $2 -n 4 --numeric-suffixes=1 -d $1.asc qr_
    for f in qr_*; do cat ${f} | qrencode -o $1_${f}.png; done

    # Archive the QR images:
    tar -cvzf $1.qr.tar.gz ./*qr_*.png

    # Cleanup:
    $3 $1.asc *qr_* > /dev/null 2>&1
    exit 0
}
