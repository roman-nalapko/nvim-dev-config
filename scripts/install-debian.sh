#!/usr/bin/env bash
set -euo pipefail

repo_root=${NVIM_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck disable=SC1091
source "$repo_root/scripts/lib.sh"

packages=(
  git curl ca-certificates ripgrep fd-find shellcheck
  build-essential cmake ninja-build clang clangd clang-format lldb
  nasm fpc python3 python3-venv python3-pip unzip xz-utils fontconfig
)

print_packages() {
  printf '%s\n' "${packages[@]}"
  printf '%s\n' nvim-linux-x86_64 tree-sitter-cli jetbrains-mono-nerd-font \
    python-tool:basedpyright python-tool:ruff stylua ghostty-if-available
}

install_stylua() {
  local version=2.5.2 expected temp_dir archive install_root
  expected=ca6f1cf52eaf69e6632b81acef9c197aa24b85eb30d2455a35e7dbe28ae77c72

  if command -v stylua >/dev/null 2>&1; then
    return 0
  fi
  temp_dir=$(mktemp -d)
  archive="$temp_dir/stylua-linux-x86_64-musl.zip"
  curl --fail --location --silent --show-error --retry 3 \
    --connect-timeout 15 --max-time 180 \
    "https://github.com/JohnnyMorganz/StyLua/releases/download/v${version}/stylua-linux-x86_64-musl.zip" \
    --output "$archive"
  printf '%s  %s\n' "$expected" "$archive" | sha256sum --check -
  unzip -q "$archive" -d "$temp_dir/extracted"
  chmod +x "$temp_dir/extracted/stylua"
  install_root="$HOME/.local/opt/stylua-$version"
  mkdir -p "$install_root"
  mv "$temp_dir/extracted/stylua" "$install_root/stylua"
  backup_and_link "$install_root/stylua" "$HOME/.local/bin/stylua"
  rm -rf "$temp_dir"
}

install_nerd_font() {
  local version=3.5.1 expected temp_dir archive font_dir
  expected=04d5e8f903693f9dd13e16f867e994834e681eb3c72c0d337a770dcda09010cf
  font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont-v$version"

  if [[ -f "$font_dir/.nvim-dev-config-version" ]]; then
    return 0
  fi
  temp_dir=$(mktemp -d)
  archive="$temp_dir/JetBrainsMono.tar.xz"
  curl --fail --location --silent --show-error --retry 3 \
    --connect-timeout 15 --max-time 180 \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/JetBrainsMono.tar.xz" \
    --output "$archive"
  printf '%s  %s\n' "$expected" "$archive" | sha256sum --check -
  mkdir -p "$font_dir"
  tar -xJf "$archive" -C "$font_dir"
  printf '%s\n' "$version" >"$font_dir/.nvim-dev-config-version"
  fc-cache -f "$font_dir"
  rm -rf "$temp_dir"
}

install_tree_sitter_cli() {
  local version=0.27.0 expected temp_dir archive binary
  expected=e4a3826bcd0fe099ee3a5617767374939cbc23c4a35b5b53f5fc04142525a2c1

  if command -v tree-sitter >/dev/null 2>&1; then
    return 0
  fi
  temp_dir=$(mktemp -d)
  archive="$temp_dir/tree-sitter-cli-linux-x64.zip"
  curl --fail --location --silent --show-error --retry 3 \
    --connect-timeout 15 --max-time 180 \
    "https://github.com/tree-sitter/tree-sitter/releases/download/v${version}/tree-sitter-cli-linux-x64.zip" \
    --output "$archive"
  printf '%s  %s\n' "$expected" "$archive" | sha256sum --check -
  unzip -q "$archive" -d "$temp_dir/extracted"
  binary="$temp_dir/extracted/tree-sitter"
  chmod +x "$binary"
  mkdir -p "$HOME/.local/opt/tree-sitter-cli-$version"
  mv "$binary" "$HOME/.local/opt/tree-sitter-cli-$version/tree-sitter"
  backup_and_link "$HOME/.local/opt/tree-sitter-cli-$version/tree-sitter" "$HOME/.local/bin/tree-sitter"
  rm -rf "$temp_dir"
}

install_neovim() {
  local current temp_dir archive checksum install_root extracted
  if command -v nvim >/dev/null 2>&1; then
    current=$(nvim --version | awk 'NR == 1 { sub(/^NVIM v/, ""); print }')
    if dpkg --compare-versions "$current" ge 0.12.0; then
      log "Neovim $current already satisfies >= 0.12.0"
      return 0
    fi
  fi

  [[ "$(uname -m)" == x86_64 ]] || {
    die "this Debian installer targets x86-64, got $(uname -m)"
    return 1
  }

  temp_dir=$(mktemp -d)
  archive="$temp_dir/nvim-linux-x86_64.tar.gz"
  checksum="$temp_dir/shasum.txt"
  curl --fail --location --silent --show-error --retry 3 \
    --connect-timeout 15 --max-time 300 \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    --output "$archive"
  curl --fail --location --silent --show-error --retry 3 \
    --connect-timeout 15 --max-time 60 \
    https://github.com/neovim/neovim/releases/latest/download/shasum.txt \
    --output "$checksum"
  (cd "$temp_dir" && grep '  nvim-linux-x86_64.tar.gz$' shasum.txt | sha256sum --check -)
  tar -xzf "$archive" -C "$temp_dir"

  install_root="$HOME/.local/opt/nvim-linux-x86_64"
  extracted="$temp_dir/nvim-linux-x86_64"
  if [[ -e "$install_root" ]]; then
    mv "$install_root" "${install_root}.backup-$(date '+%Y%m%d-%H%M%S')"
  fi
  mkdir -p "$(dirname "$install_root")"
  mv "$extracted" "$install_root"
  backup_and_link "$install_root/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$temp_dir"
}

case "${1:-}" in
  --print-packages) print_packages; exit 0 ;;
  --config-only|'') ;;
  *) die "unknown argument: $1"; exit 2 ;;
esac

require_platform debian x86_64

if [[ "${1:-}" != --config-only ]]; then
  if ((EUID == 0)); then
    apt=(apt-get)
  else
    command -v sudo >/dev/null 2>&1 || { die 'sudo is required for APT'; exit 1; }
    apt=(sudo apt-get)
  fi
  "${apt[@]}" -o Acquire::Retries=3 -o Acquire::http::Timeout=30 update
  "${apt[@]}" -o Acquire::Retries=3 -o Acquire::http::Timeout=30 install -y "${packages[@]}"
  install_neovim
  install_tree_sitter_cli
  install_stylua
  install_nerd_font
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    backup_and_link "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if ! command -v lldb-dap >/dev/null 2>&1; then
    if lldb_dap=$(find_lldb_dap); then
      backup_and_link "$lldb_dap" "$HOME/.local/bin/lldb-dap"
    else
      log 'LLDB-DAP was not found; C/C++ debugging will remain unavailable.'
    fi
  fi

  if apt-cache show ghostty >/dev/null 2>&1; then
    "${apt[@]}" -o Acquire::Retries=3 install -y ghostty
  else
    log 'Ghostty is not in this Debian repository; see README for verified alternatives.'
  fi
  setup_debugpy
  setup_python_tools
fi

install_configs "$repo_root"
log 'Debian setup complete'
