#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT

fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }
pass() { printf 'ok - %s\n' "$1"; }

create_repository() {
  mkdir -p "$test_root/repo/scripts"
  git -C "$test_root/repo" init -q
  git -C "$test_root/repo" config user.name Test
  git -C "$test_root/repo" config user.email test@example.invalid
  printf 'tracked\n' >"$test_root/repo/tracked.txt"
  git -C "$test_root/repo" add tracked.txt
  git -C "$test_root/repo" commit -qm initial
}

help=$("$repo_root/scripts/update.sh" --help)
[[ "$help" == *'--dry-run'* ]] || fail 'help omits --dry-run'
[[ "$help" == *'--with-packages'* ]] || fail 'help omits --with-packages'
pass 'update help documents safe modes'

create_repository
report=$(NVIM_SETUP_REPO_ROOT="$test_root/repo" "$repo_root/scripts/update.sh" --dry-run)
[[ "$report" == *'git pull --ff-only'* ]] || fail 'dry-run omits fast-forward-only pull'
[[ "$report" == *'install.sh --config-only'* ]] || fail 'dry-run omits config refresh'
[[ "$report" == *'Lazy! restore'* ]] || fail 'dry-run does not restore the committed plugin lock'
[[ "$report" == *"require('config.treesitter').install():wait(300000)"* ]] || fail 'dry-run omits synchronous parser installation'
[[ "$report" == *"require('config.treesitter').update():wait(300000)"* ]] || fail 'dry-run omits synchronous parser update'
[[ "$report" == *'healthcheck.sh --strict'* ]] || fail 'dry-run omits strict healthcheck'
pass 'default dry-run reports the complete safe update lifecycle'

package_report=$(NVIM_SETUP_REPO_ROOT="$test_root/repo" "$repo_root/scripts/update.sh" --dry-run --with-packages)
[[ "$package_report" == *'/scripts/install.sh'* ]] || fail 'package update omits installer'
[[ "$package_report" != *'install.sh --config-only'* ]] || fail 'package update still uses config-only mode'
pass 'package refresh is explicit'

printf 'changed\n' >"$test_root/repo/tracked.txt"
if NVIM_SETUP_REPO_ROOT="$test_root/repo" "$repo_root/scripts/update.sh" --dry-run >"$test_root/out" 2>"$test_root/err"; then
  fail 'update accepted a dirty repository'
fi
grep -Fq 'working tree is not clean' "$test_root/err" || fail 'dirty repository error is unclear'
[[ ! -s "$test_root/out" ]] || fail 'dirty update started commands before refusing'
pass 'update refuses local changes before external actions'
