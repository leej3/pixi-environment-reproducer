#!/bin/sh
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
mkdir -p "$script_dir/results"
printf '%s\n' 'Testing Pixi 0.81.0'
docker run --rm --platform linux/amd64 -i ghcr.io/prefix-dev/pixi@sha256:788ae451641666e2d1f79d3dbe35392dfc7e9b394b16a3acb75c347f3badb2ab sh < "$script_dir/reproduce.sh" > "$script_dir/results/0.81.0.log" 2>&1
grep -F 'DIRECT_RESULT=' "$script_dir/results/0.81.0.log"
printf '%s\n' 'Testing Pixi 0.82.0'
docker run --rm --platform linux/amd64 -i ghcr.io/prefix-dev/pixi@sha256:e6cca082e52de275f4e6fb4e6648522f30e4ed334fed37378cde393e07405200 sh < "$script_dir/reproduce.sh" > "$script_dir/results/0.82.0.log" 2>&1
grep -F 'DIRECT_RESULT=' "$script_dir/results/0.82.0.log"
printf '%s\n' 'Testing Pixi 0.82.1'
docker run --rm --platform linux/amd64 -i ghcr.io/prefix-dev/pixi@sha256:f83a5fc6d1bb9a2ced27faf2b26c04c5eb618eed22fe13eb60f9225db4817ce0 sh < "$script_dir/reproduce.sh" > "$script_dir/results/0.82.1.log" 2>&1
grep -F 'DIRECT_RESULT=' "$script_dir/results/0.82.1.log"
printf '%s\n' 'Testing Pixi 0.83.0'
docker run --rm --platform linux/amd64 -i ghcr.io/prefix-dev/pixi@sha256:3dce86c6e87371c58035aa41b09f2b56ca8f011722320551e0c2bfc1c59da5fb sh < "$script_dir/reproduce.sh" > "$script_dir/results/0.83.0.log" 2>&1
grep -F 'DIRECT_RESULT=' "$script_dir/results/0.83.0.log"
