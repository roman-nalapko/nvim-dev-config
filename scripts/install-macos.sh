#!/usr/bin/env bash
set -euo pipefail

repo_root=${NVIM_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck disable=SC1091
source "$repo_root/scripts/lib.sh"

formulae=(
  neovim git cmake ninja llvm lldb fpc nasm ripgrep fd shellcheck
  basedpyright ruff stylua tree-sitter-cli python
)
casks=(ghostty font-jetbrains-mono-nerd-font)

case "${1:-}" in
  --print-packages)
    printf '%s\n' "${formulae[@]}"
    printf 'cask:%s\n' "${casks[@]}"
    exit 0
    ;;
  --config-only|'') ;;
  *) die "unknown argument: $1"; exit 2 ;;
esac

if [[ "${1:-}" != --config-only ]]; then
  command -v brew >/dev/null 2>&1 || {
    die 'Homebrew is required: https://brew.sh'
    exit 1
  }
  export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_CURL_RETRIES=3
  brew install "${formulae[@]}"
  brew install --cask "${casks[@]}"
  setup_debugpy
fi

install_configs "$repo_root"
log 'macOS setup complete'
