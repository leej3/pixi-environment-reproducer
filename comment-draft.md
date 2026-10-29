The minimal reproducer adds a PyPI source dependency directly to a new environment:

```sh
pixi add --environment plotting --pypi env-repro --path ./local
```

The local package supplies its metadata through `setup.py`, requiring Pixi to invoke its build backend.
This fails on Pixi 0.81.0, 0.82.0, 0.82.1, and 0.83.0 in the official Linux amd64 containers.
Versions 0.81.0 and 0.82.0 print a Rust panic; 0.82.1 and 0.83.0 report the missing-environment error without printing a panic.
Creating the environment first works on all four versions:

```sh
pixi workspace environment add plotting
pixi add --environment plotting --pypi env-repro --path ./local
```

A related case occurred in our original workflow when running:

```sh
pixi add --environment plotting matplotlib
```

Here Matplotlib was a conda dependency, but the new environment also inherited PyPI dependencies from the workspace's default feature.
The failure occurred during resolution of those PyPI dependencies, with the same missing-environment error.
We have not identified the particular inherited package that triggered backend execution, so the reproducer uses an explicit local source dependency to isolate that condition.
