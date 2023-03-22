#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

for var in "$@"
do
    find "$var"/ -name '*.sh' -exec chmod a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod a+x {} +
    chgrp -R 0 "$var" && chmod -R a+rw "$var" && find "$var" -type d -exec chmod a+x {} +
done