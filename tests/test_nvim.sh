#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

cd "$repo_root"
XDG_STATE_HOME="$test_root/state" \
XDG_DATA_HOME="$test_root/data" \
XDG_CACHE_HOME="$test_root/cache" \
  nvim --headless -u NONE -l tests/nvim_smoke.lua
