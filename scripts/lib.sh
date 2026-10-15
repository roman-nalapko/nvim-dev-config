#!/usr/bin/env bash

log() {
  printf '[nvim-dev-config] %s\n' "$*"
}

die() {
  printf '[nvim-dev-config] error: %s\n' "$*" >&2
  return 1
}

canonical_path() {
  local path=$1 parent name
  parent=$(cd "$(dirname "$path")" 2>/dev/null && pwd -P) || return 1
  name=$(basename "$path")
  printf '%s/%s\n' "$parent" "$name"
}

backup_and_link() {
  local source=$1 target=$2 source_abs current suffix backup

  [[ -e "$source" ]] || {
    die "source does not exist: $source"
    return 1
  }
  source_abs=$(canonical_path "$source") || {
    die "cannot resolve source: $source"
    return 1
  }

  if [[ -L "$target" ]]; then
    current=$(readlink "$target")
    if [[ "$current" == "$source_abs" ]]; then
      log "already linked: $target"
      return 0
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    suffix=${NVIM_SETUP_BACKUP_SUFFIX:-$(date '+%Y%m%d-%H%M%S')}
    backup="${target}.backup-${suffix}"
    if [[ -e "$backup" || -L "$backup" ]]; then
      die "backup target already exists: $backup"
      return 1
    fi
    mv "$target" "$backup"
    log "backed up $target to $backup"
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source_abs" "$target"
  log "linked $target -> $source_abs"
}

detect_platform() {
  local kernel os_id
  kernel=${NVIM_SETUP_UNAME:-$(uname -s)}

  case "$kernel" in
    Darwin)
      printf 'macos\n'
      ;;
    Linux)
      if [[ -n "${NVIM_SETUP_OS_ID:-}" ]]; then
        os_id=$NVIM_SETUP_OS_ID
      elif [[ -r /etc/os-release ]]; then
        os_id=$(
          # shellcheck disable=SC1091
          . /etc/os-release
          printf '%s' "${ID:-}"
        )
      fi
      if [[ "$os_id" == debian ]]; then
        printf 'debian\n'
      else
        die "unsupported Linux distribution: ${os_id:-unknown}"
        return 1
      fi
      ;;
    *)
      die "unsupported operating system: $kernel"
      return 1
      ;;
  esac
}
