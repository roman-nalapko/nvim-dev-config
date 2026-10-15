#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck disable=SC1091
source "$repo_root/scripts/lib.sh"

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [--config-only]

Install dependencies and link the Neovim and Ghostty configurations for the
current platform. Use --config-only to skip package installation.
EOF
}

config_only=0
case "${1:-}" in
  '') ;;
  --config-only) config_only=1 ;;
  -h|--help) usage; exit 0 ;;
  *) die "unknown argument: $1"; usage >&2; exit 2 ;;
esac

platform=$(detect_platform)
platform_script="$repo_root/scripts/install-${platform}.sh"
[[ -x "$platform_script" ]] || {
  die "platform installer is not available yet: $platform_script"
  exit 1
}

args=()
if ((config_only)); then
  args+=(--config-only)
fi
exec "$platform_script" "${args[@]}"
