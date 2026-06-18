#!/bin/bash
set -euo pipefail
source /home/ismail/dev/al_hadith/parts/al-hadith/run/environment.sh
set -x
cp --archive --link --no-dereference . "/home/ismail/dev/al_hadith/parts/al-hadith/install"
