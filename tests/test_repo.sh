#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck disable=SC1091
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

assert_contains() {
  local haystack=$1 needle=$2 message=$3
  [[ "$haystack" == *"$needle"* ]] || fail "$message (missing '$needle')"
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
  local NVIM_SETUP_BACKUP_SUFFIX=test
  export NVIM_SETUP_BACKUP_SUFFIX
  new_fixture
  mkdir -p "$test_root/home/.config/nvim"
  printf 'user data\n' >"$test_root/home/.config/nvim/keep.txt"
  backup_and_link "$test_root/repo/nvim" "$test_root/home/.config/nvim"

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
  local NVIM_SETUP_BACKUP_SUFFIX=test
  export NVIM_SETUP_BACKUP_SUFFIX
  new_fixture
  mkdir -p "$test_root/home/.config/nvim" "$test_root/home/.config/nvim.backup-test"
  if backup_and_link "$test_root/repo/nvim" "$test_root/home/.config/nvim" >/dev/null 2>&1; then
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

test_platform_package_manifests() {
  local mac_packages debian_packages
  mac_packages=$("$repo_root/scripts/install-macos.sh" --print-packages)
  assert_contains "$mac_packages" neovim 'macOS manifest lacks Neovim'
  assert_contains "$mac_packages" ghostty 'macOS manifest lacks Ghostty'
  assert_contains "$mac_packages" fpc 'macOS manifest lacks Free Pascal'
  assert_contains "$mac_packages" nasm 'macOS manifest lacks NASM'

  debian_packages=$("$repo_root/scripts/install-debian.sh" --print-packages)
  assert_contains "$debian_packages" clangd 'Debian manifest lacks clangd'
  assert_contains "$debian_packages" fpc 'Debian manifest lacks Free Pascal'
  assert_contains "$debian_packages" nasm 'Debian manifest lacks NASM'
  assert_contains "$debian_packages" nvim-linux-x86_64 'Debian manifest lacks official Neovim build'
  pass 'platform package manifests cover the required toolchains'
}

test_config_only_install_is_idempotent() {
  new_fixture
  HOME="$test_root/home" XDG_CONFIG_HOME="$test_root/config" \
    "$repo_root/scripts/install-macos.sh" --config-only >/dev/null
  [[ -L "$test_root/config/nvim" ]] || fail 'config-only install did not link Neovim'
  [[ -L "$test_root/config/ghostty" ]] || fail 'config-only install did not link Ghostty'

  HOME="$test_root/home" XDG_CONFIG_HOME="$test_root/config" \
    "$repo_root/scripts/install-macos.sh" --config-only >/dev/null
  if find "$test_root/config" -maxdepth 1 -name '*.backup-*' | grep -q .; then
    fail 'repeated config-only install created backups'
  fi
  pass 'config-only install is idempotent'
}

test_main_installer_routes_to_debian() {
  new_fixture
  HOME="$test_root/home" XDG_CONFIG_HOME="$test_root/config" \
    NVIM_SETUP_UNAME=Linux NVIM_SETUP_OS_ID=debian \
    "$repo_root/scripts/install.sh" --config-only >/dev/null
  [[ -L "$test_root/config/nvim" ]] || fail 'main installer did not route to Debian config install'
  pass 'main installer routes Debian without package side effects'
}

test_ghostty_transparency_and_read_only_healthcheck() {
  new_fixture
  local opacity before after report
  opacity=$(awk -F '=' '$1 ~ /^background-opacity[[:space:]]*$/ { gsub(/[[:space:]]/, "", $2); print $2 }' "$repo_root/ghostty/config.ghostty")
  assert_eq 0.86 "$opacity" 'Ghostty opacity is not the designed value'

  before=$(find "$test_root" -print | sort)
  report=$(HOME="$test_root/home" XDG_CONFIG_HOME="$test_root/config" "$repo_root/scripts/healthcheck.sh")
  after=$(find "$test_root" -print | sort)
  assert_eq "$before" "$after" 'healthcheck modified the filesystem'
  assert_contains "$report" 'Neovim' 'healthcheck omits Neovim'
  assert_contains "$report" 'Ghostty' 'healthcheck omits Ghostty'
  pass 'Ghostty is transparent and healthcheck is read-only'
}

test_missing_source_is_rejected
test_real_directory_is_backed_up
test_missing_parent_is_created
test_repeated_run_is_idempotent
test_backup_collision_is_rejected
test_platform_detection
test_platform_package_manifests
test_config_only_install_is_idempotent
test_main_installer_routes_to_debian
test_ghostty_transparency_and_read_only_healthcheck

printf '1..%d\n' "$tests_run"
