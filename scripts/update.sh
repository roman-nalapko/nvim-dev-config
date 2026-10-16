#!/usr/bin/env bash
set -euo pipefail

repo_root=${NVIM_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}

usage() {
  cat <<'EOF'
Usage: scripts/update.sh [--dry-run] [--with-packages]

Update this checkout with a fast-forward-only pull, restore the committed
plugin lock, update configured Treesitter parsers, and run a strict health
check. By default, system packages are not changed.

Options:
  --dry-run        Print the lifecycle without changing anything.
  --with-packages  Re-run the platform package installer.
  -h, --help       Show this help.
EOF
}

dry_run=0
with_packages=0
while (($#)); do
  case "$1" in
    --dry-run) dry_run=1 ;;
    --with-packages) with_packages=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf '[nvim-dev-config] error: unknown argument: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

[[ -d "$repo_root/.git" ]] || {
  printf '[nvim-dev-config] error: not a Git checkout: %s\n' "$repo_root" >&2
  exit 1
}
if [[ -n "$(git -C "$repo_root" status --porcelain --untracked-files=normal)" ]]; then
  printf '[nvim-dev-config] error: working tree is not clean; commit or stash changes first\n' >&2
  exit 1
fi

run() {
  if ((dry_run)); then
    printf 'DRY-RUN'
    printf ' %s' "$@"
    printf '\n'
  else
    "$@"
  fi
}

pull_repository() {
  if ((dry_run)); then
    printf 'DRY-RUN git pull --ff-only (in %s)\n' "$repo_root"
  else
    git -C "$repo_root" pull --ff-only
  fi
}

if ((!dry_run)); then
  command -v git >/dev/null 2>&1 || { printf '[nvim-dev-config] error: git is required\n' >&2; exit 1; }
  command -v nvim >/dev/null 2>&1 || { printf '[nvim-dev-config] error: nvim is required\n' >&2; exit 1; }
  [[ -x "$repo_root/scripts/install.sh" ]] || { printf '[nvim-dev-config] error: scripts/install.sh is missing\n' >&2; exit 1; }
  [[ -x "$repo_root/scripts/healthcheck.sh" ]] || { printf '[nvim-dev-config] error: scripts/healthcheck.sh is missing\n' >&2; exit 1; }
fi

pull_repository
if ((with_packages)); then
  run "$repo_root/scripts/install.sh"
else
  run "$repo_root/scripts/install.sh" --config-only
fi
run nvim --headless '+Lazy! restore' '+qa!'
run nvim --headless "+lua require('config.treesitter').install():wait(300000)" '+qa!'
run nvim --headless "+lua require('config.treesitter').update():wait(300000)" '+qa!'
run "$repo_root/scripts/healthcheck.sh" --strict
