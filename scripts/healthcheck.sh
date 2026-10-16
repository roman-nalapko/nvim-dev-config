#!/usr/bin/env bash
set -euo pipefail

repo_root=${NVIM_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck disable=SC1091
source "$repo_root/scripts/lib.sh"

strict=0
if [[ "${1:-}" == --strict ]]; then
  strict=1
elif [[ -n "${1:-}" ]]; then
  printf 'Usage: scripts/healthcheck.sh [--strict]\n' >&2
  exit 2
fi

missing=0
check() {
  local label=$1 command=$2 required=${3:-optional}
  if command -v "$command" >/dev/null 2>&1; then
    printf 'OK      %-16s %s\n' "$label" "$(command -v "$command")"
  else
    printf 'MISSING %-16s %s\n' "$label" "$required"
    if [[ "$required" == required ]]; then
      missing=$((missing + 1))
    fi
  fi
}

check_path() {
  local label=$1 path=$2 required=${3:-optional}
  if [[ -e "$path" ]]; then
    printf 'OK      %-16s %s\n' "$label" "$path"
  else
    printf 'MISSING %-16s %s\n' "$label" "$required"
    if [[ "$required" == required ]]; then
      missing=$((missing + 1))
    fi
  fi
}

check Neovim nvim required
check Git git required
applications_dir=${NVIM_SETUP_APPLICATIONS_DIR:-/Applications}
if command -v ghostty >/dev/null 2>&1; then
  check Ghostty ghostty optional
else
  check_path Ghostty "$applications_dir/Ghostty.app" optional
fi
check clangd clangd optional
check CMake cmake optional
check clang-format clang-format optional
if lldb_dap=$(find_lldb_dap 2>/dev/null); then
  check_path LLDB-DAP "$lldb_dap" optional
else
  printf 'MISSING %-16s %s\n' LLDB-DAP optional
fi
check Python python3 optional
check Ruff ruff optional
check basedpyright basedpyright-langserver optional
check Free-Pascal fpc optional
check NASM nasm optional
check ripgrep rg optional
check fd fd optional

config_home=${XDG_CONFIG_HOME:-$HOME/.config}
for name in nvim ghostty; do
  if [[ -L "$config_home/$name" ]]; then
    printf 'OK      %-16s %s\n' "$name-config" "$(readlink "$config_home/$name")"
  elif [[ -e "$config_home/$name" ]]; then
    printf 'NOTICE  %-16s real path (not managed symlink)\n' "$name-config"
  else
    printf 'MISSING %-16s not installed\n' "$name-config"
  fi
done

if ((strict && missing)); then
  exit 1
fi
