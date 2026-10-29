# Pixi: adding a new environment fails when PyPI metadata needs a build

Tested 2026-10-29 using official `ghcr.io/prefix-dev/pixi` containers, Ubuntu 24.04, explicitly selecting `linux/amd64`.
Docker Desktop ran these x86-64 containers on an Apple Silicon host.
Each run had a fresh filesystem and package cache; no project files or host caches were mounted.

| Pixi | Direct `add --environment plotting` | Explicit creation workaround |
| --- | --- | --- |
| 0.81.0 | Exit 1; Rust panic and missing environment error | Pass |
| 0.82.0 | Exit 1; Rust panic and missing environment error | Pass |
| 0.82.1 | Exit 1; missing environment error, no panic printed | Pass |
| 0.83.0 | Exit 1; missing environment error, no panic printed | Pass |

0.83.0 was the latest published release checked.
Version tags and resolved image digests are in `images.json`; the matrix runner uses those digests.
The original observed outputs are in the four version-named `.log` files.

## Reproduce

Prerequisites: Docker running, plus network access to GHCR, conda-forge, and PyPI.
From this directory:

```sh
docker run --rm --platform linux/amd64 -i \
  ghcr.io/prefix-dev/pixi:0.83.0 sh < reproduce.sh
```

To repeat all four tests using the recorded image digests:

```sh
sh run-matrix.sh
```

New logs go to `results/`.
`reproduce.sh` exits zero only if it observes the specific defect and the workaround succeeds.
Exit 2 means the direct command succeeded (the bug was not reproduced); other failures exit nonzero.

## What the script does

Creates a tiny local Python package whose name and version are supplied by `setup.py`, so Pixi must invoke setuptools to discover its metadata.
Python is constrained to 3.13 and the build backend to setuptools 80.9.0.
The conda solve is live, not frozen by a lockfile.

This fails when `plotting` does not yet exist:

```sh
pixi add --environment plotting --pypi env-repro --path ./local
```

The latest tested version reports:

```text
failed to solve the pypi requirements of environment 'plotting' for
platform 'linux-64'
build dispatch initialization failed
environment 'plotting' should have been created during workspace creation
```

Expected: create the environment, resolve and install the local package.

In a separate fresh workspace, these commands succeed:

```sh
pixi workspace environment add plotting
pixi add --environment plotting --pypi env-repro --path ./local
```

The script also verifies that the installed package is version 0.0.1.
No Gaia data, scientific dependencies, DataLad, or credentials are needed.

Official container source: https://github.com/prefix-dev/pixi-docker Release list: https://github.com/prefix-dev/pixi/releases
