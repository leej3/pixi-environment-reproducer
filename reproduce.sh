#!/bin/sh
set -eu

# Run inside an official Pixi container. No host files or caches are required.
workdir=$(mktemp -d)
cd "$workdir"
printf 'Workspace: %s\n' "$workdir"
pixi --version

pixi init
pixi add python

# The package requires running its build backend to discover its metadata.
if pixi add --environment plotting --pypi docopt==0.6.2 > direct.log 2>&1; then
    cat direct.log
    echo 'DIRECT_RESULT=success (bug not reproduced)'
    exit 2
else
    result=$?
    cat direct.log
    printf 'DIRECT_EXIT=%s\n' "$result"
    if tr '\n' ' ' < direct.log | tr -s ' ' | grep -Eq "plotting.*should (be already|have been) created during"; then
        echo 'DIRECT_RESULT=bug-reproduced'
    else
        echo 'Unexpected failure: this does not establish reproduction.' >&2
        exit 1
    fi
fi
