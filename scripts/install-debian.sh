#!/usr/bin/env bash
set -euo pipefail

repo_root=${NVIM_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
# shellcheck disable=SC1091
source "$repo_root/scripts/lib.sh"

packages=(
  git curl ca-certificates ripgrep fd-find shellcheck
  build-essential cmake ninja-build clang clangd clang-format lldb
  nasm fpc python3 python3-venv python3-pip unzip xz-utils
)

print_packages() {
  printf '%s\n' "${packages[@]}"
  printf '%s\n' nvim-linux-x86_64 ghostty-if-available
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
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    backup_and_link "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if apt-cache show ghostty >/dev/null 2>&1; then
    "${apt[@]}" -o Acquire::Retries=3 install -y ghostty
  else
    log 'Ghostty is not in this Debian repository; see README for verified alternatives.'
  fi
  setup_debugpy
fi

install_configs "$repo_root"
log 'Debian setup complete'
