# Pixi fails when adding a source package to a new environment

A minimal local Python package supplies its metadata through `setup.py`.
Adding it directly to a new environment fails:

```sh
pixi add --environment plotting --pypi env-repro --path ./local
```

Expected: create the environment and install the package.
Actual on 0.83.0: `environment 'plotting' should have been created during workspace creation`.

## Reproduce

With Docker running and network access to GHCR, conda-forge, and PyPI:

```sh
docker run --rm --platform linux/amd64 -i \
  ghcr.io/prefix-dev/pixi:0.83.0 sh < reproduce.sh
```

The script creates the entire example in a temporary directory.
It contains one package, one dependency-add command, and a check for the specific error.
Python is constrained to 3.13 and setuptools to 80.9.0; the conda solve remains live.
Exit 0 confirms the bug, exit 2 means the command succeeded, and other failures exit nonzero.

## Fresh results for this minimal example

Tested 2026-10-29 in fresh official Ubuntu 24.04 containers using `linux/amd64` on Docker Desktop on Apple Silicon.
No host project files or package caches were mounted.

| Pixi | Result |
| --- | --- |
| 0.81.0 | Exit 1; missing environment error with Rust panic |
| 0.82.0 | Exit 1; missing environment error with Rust panic |
| 0.82.1 | Exit 1; missing environment error without printed panic |
| 0.83.0 | Exit 1; missing environment error without printed panic |

The four version-named `.log` files record these runs.
To repeat the minimal example across all four digest-pinned images:

```sh
sh run-matrix.sh
```

New logs go to `results/`; image references are recorded in `images.json`.
The related inherited-dependency case is described separately in [the unposted comment](comment-draft.md).

[Official containers](https://github.com/prefix-dev/pixi-docker) · [Pixi releases](https://github.com/prefix-dev/pixi/releases)
