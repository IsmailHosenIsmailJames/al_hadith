#!/bin/bash
set -euo pipefail
source /home/ismail/dev/al_hadith/parts/gnome/sdk/run/environment.sh
set -x
make -j"12"
make -j"12" install DESTDIR="/home/ismail/dev/al_hadith/parts/gnome/sdk/install"
