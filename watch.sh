#!/bin/bash

# This is a script that watches for changes in the "zig-src" dir and rebuilds.
# The purpose is to allow for an interative design loop with Zig and Svelte togetther

# Vars
hash=$(ls -lR ./zig/ | sha1sum)
exit=""
if [ "$1" = "USE_NODE=1" ]; then
    USENODE="1"
else
    USENODE="0"
fi

# Exit behavior
trap "exit" INT TERM
trap "kill 0" EXIT

echo "Starting"
((make web USE_NODE=$USENODE) && "" || exit) &

echo "Press any key to exit"
until [ "$exit" = "yes" ]; do
    newHash=$(ls -lR ./zig/ | sha1sum)
    if [ "$hash" != "$newHash" ]; then
        hash=$newHash
        echo "New Hash Detected Rebuilding"
        make build-web
    fi
    read -n1 -t 2 && exit="yes"
done