#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=../scripts/lib.sh
source "$repo_root/scripts/lib.sh"

tests_run=0
test_root=""

cleanup() {
  if [[ -n "$test_root" && -d "$test_root" ]]; then
    rm -rf "$test_root"
  fi
}
trap cleanup EXIT

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

pass() {
  tests_run=$((tests_run + 1))
  printf 'ok %d - %s\n' "$tests_run" "$1"
}

assert_eq() {
  local expected=$1 actual=$2 message=$3
  [[ "$actual" == "$expected" ]] || fail "$message (expected '$expected', got '$actual')"
}

new_fixture() {
  cleanup
  test_root=$(mktemp -d)
  mkdir -p "$test_root/repo/nvim"
  printf 'fixture\n' >"$test_root/repo/nvim/init.lua"
}

fixture_source_path() {
  printf '%s/nvim\n' "$(cd "$test_root/repo" && pwd -P)"
}

test_missing_source_is_rejected() {
  new_fixture
  if backup_and_link "$test_root/missing" "$test_root/home/.config/nvim" >/dev/null 2>&1; then
    fail 'missing source must be rejected'
  fi
  [[ ! -e "$test_root/home/.config/nvim" ]] || fail 'missing source changed target'
  pass 'missing source is rejected without changing target'
}

test_real_directory_is_backed_up() {
  new_fixture
  mkdir -p "$test_root/home/.config/nvim"
  printf 'user data\n' >"$test_root/home/.config/nvim/keep.txt"
  NVIM_SETUP_BACKUP_SUFFIX=test backup_and_link \
    "$test_root/repo/nvim" "$test_root/home/.config/nvim"

  [[ -f "$test_root/home/.config/nvim.backup-test/keep.txt" ]] || fail 'existing directory was not backed up'
  [[ -L "$test_root/home/.config/nvim" ]] || fail 'target is not a symlink'
  assert_eq "$(fixture_source_path)" "$(readlink "$test_root/home/.config/nvim")" 'symlink points to wrong source'
  pass 'existing directory is backed up before linking'
}

test_missing_parent_is_created() {
  new_fixture
  backup_and_link "$test_root/repo/nvim" "$test_root/new/home/.config/nvim"
  [[ -L "$test_root/new/home/.config/nvim" ]] || fail 'target symlink was not created'
  pass 'missing target parents are created'
}

test_repeated_run_is_idempotent() {
  new_fixture
  backup_and_link "$test_root/repo/nvim" "$test_root/home/.config/nvim"
  NVIM_SETUP_BACKUP_SUFFIX=second backup_and_link \
    "$test_root/repo/nvim" "$test_root/home/.config/nvim"
  [[ ! -e "$test_root/home/.config/nvim.backup-second" ]] || fail 'idempotent run created a backup'
  assert_eq "$(fixture_source_path)" "$(readlink "$test_root/home/.config/nvim")" 'idempotent run changed link'
  pass 'repeated run keeps the correct link without a backup'
}

test_backup_collision_is_rejected() {
  new_fixture
  mkdir -p "$test_root/home/.config/nvim" "$test_root/home/.config/nvim.backup-test"
  if NVIM_SETUP_BACKUP_SUFFIX=test backup_and_link \
    "$test_root/repo/nvim" "$test_root/home/.config/nvim" >/dev/null 2>&1; then
    fail 'backup collision must be rejected'
  fi
  [[ -d "$test_root/home/.config/nvim" ]] || fail 'collision changed original target'
  pass 'backup collision leaves the original target untouched'
}

test_platform_detection() {
  assert_eq macos "$(NVIM_SETUP_UNAME=Darwin detect_platform)" 'Darwin platform detection failed'
  assert_eq debian "$(NVIM_SETUP_UNAME=Linux NVIM_SETUP_OS_ID=debian detect_platform)" 'Debian platform detection failed'
  if NVIM_SETUP_UNAME=Linux NVIM_SETUP_OS_ID=fedora detect_platform >/dev/null 2>&1; then
    fail 'unsupported Linux distribution must be rejected'
  fi
  pass 'platform detection accepts macOS and Debian only'
}

test_missing_source_is_rejected
test_real_directory_is_backed_up
test_missing_parent_is_created
test_repeated_run_is_idempotent
test_backup_collision_is_rejected
test_platform_detection

printf '1..%d\n' "$tests_run"
