#!/bin/bash

set -x

cd ~

wget -O dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py

chmod +x dropbox.py

wget wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

~/.dropbox-dist/dropboxd
