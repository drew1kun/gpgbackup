# gpgpaper
Back up your gpg private keys to printable QR codes, and restore them from scanned PNG images.

[![BSD licensed][bsd-badge]][bsd-link]

## What does it do?

The script will create a directory with your gpg `<Key_ID>` name and put all the files there.
`<Key_ID>` - gpg key identity: may be an email or key fingerprint like: `5F8C67D3`

For recovering of the key the `gpgpaper.sh` script searches for a directory named `<Key_ID>`, containig PNG files with
QR-Codes. It's just that simple.

**IMPORTANT:**

1 - Order of PNG files matters! PNGs must be numbered properly, so the first part of key goes first and so on.

2 - When recovering secret keys from scanned PNG files with QR-codes, the public portion of a key must be in gpg
keychain.


## Dependencies
Depends on:

  - **gpg/gpg2**
  - **paperkey**
  - **qrencode**
  - **zbar**
  - **coreutils** *(GNU version)*
  - **pdflatex** (mactex on MacOS or latex on Linux)

MacOS: install dependencies with [Homebrew][homebrew]:

```
brew install \
	gpg-suite \
	mactex-no-gui \
	coreutils \
	qrencode \
	zbar \
	paperkey
```
coreutils will be installed with `g` - prefix (stands for GNU). E.g.:  gsplit, ghead etc...

## Usage

### BACK UP SECRET GPG KEYS TO QR CODES

Option 1: Generate a tarball with 4 PNG files containing QR-Codes of specified. You can then store it on digital
storages

    ./gpgpaper.sh -k user@email.com


Option 2: Generate a printable PDF file to store your keys on paper in safe onffine storage.

    ./gpgpaper.sh -p 5F8C67D3


### RECOVER SECRET KEYS

If you stored keys on paper, then do the following:

 - scan the QR-codes,
 - save each QR-code in separate PNG file and name them accordingly:
    **1.png, 2.png, 2.png, 4.png** (Remember: **Order matters!**)
 - put all PNGs to folder named `<Key_ID>.qr`
 - Clone this repo and put the folder to the repo next to script.
 - run: `./gpgpaper.sh -r <Key_ID>`

The gpg secret key file named `<Key_ID>.asc` will be generated in the `<Key_ID>` directory.

Now you can import it using:

    gpg --import ./<Key_ID>/<Key_ID>.asc

Done!

## License

[BSD][bsd-link]

## Author Information

Andrew Shagayev | [e-mail](mailto:drewshg@gmail.com)

[bsd-badge]: https://img.shields.io/badge/license-BSD-blue.svg
[bsd-link]: https://raw.githubusercontent.com/drew1kun/gpgpaper/refs/heads/main/LICENSE
[homebrew]: http://brew.sh/
