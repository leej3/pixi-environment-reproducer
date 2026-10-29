With an empty package cache, adding docopt to a new environment fails during source metadata resolution:

```sh
mkdir test
cd test
export PIXI_CACHE_DIR="$PWD/cache"
pixi init
pixi add python
pixi add --environment plotting --pypi docopt==0.6.2
```

The published docopt 0.6.2 source distribution requires Pixi to invoke its build backend for metadata.
This fails on Pixi 0.81.0, 0.82.0, 0.82.1, and 0.83.0 in the official Linux amd64 containers.
Versions 0.81.0 and 0.82.0 print a Rust panic; 0.82.1 and 0.83.0 report the missing-environment error without printing a panic.

A fresh project alone is insufficient: cached metadata can let the command succeed.
The isolated cache above leaves any existing Pixi cache untouched.
