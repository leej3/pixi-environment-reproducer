#!/bin/sh
set -eu

# Run inside an official Pixi container. No host files or caches are required.
workdir=$(mktemp -d)
cd "$workdir"
printf 'Workspace: %s\n' "$workdir"
pixi --version
uname -m
cat /etc/os-release

mkdir local
cat > local/pyproject.toml <<'EOF'
[build-system]
requires = ["setuptools==80.9.0"]
build-backend = "setuptools.build_meta"
EOF
cat > local/setup.py <<'EOF'
from setuptools import setup
setup(name="env-repro", version="0.0.1")
EOF
cat > pixi.toml <<'EOF'
[workspace]
name = "env-repro-workspace"
channels = ["conda-forge"]
platforms = ["linux-64"]

[dependencies]
python = "3.13.*"
EOF

# The package requires running its build backend to discover its metadata.
if pixi add --environment plotting --pypi env-repro --path ./local > direct.log 2>&1; then
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

# Independently check the workaround from a fresh workspace.
mkdir workaround
cp -R local workaround/local
cat > workaround/pixi.toml <<'EOF'
[workspace]
name = "env-repro-workspace"
channels = ["conda-forge"]
platforms = ["linux-64"]

[dependencies]
python = "3.13.*"
EOF
cd workaround
pixi workspace environment add plotting
pixi add --environment plotting --pypi env-repro --path ./local
pixi run --environment plotting --locked python -c 'from importlib.metadata import version; assert version("env-repro") == "0.0.1"; print("WORKAROUND_RESULT=success")'
