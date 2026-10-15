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

require_platform() {
  local expected_platform=$1 expected_arch=$2 actual_platform actual_arch
  actual_platform=$(detect_platform) || return 1
  actual_arch=${NVIM_SETUP_ARCH:-$(uname -m)}
  [[ "$actual_platform" == "$expected_platform" ]] || {
    die "this installer requires $expected_platform, got $actual_platform"
    return 1
  }
  [[ "$actual_arch" == "$expected_arch" ]] || {
    die "this installer requires $expected_arch, got $actual_arch"
    return 1
  }
}

install_configs() {
  local repo_root=$1 config_home
  config_home=${XDG_CONFIG_HOME:-$HOME/.config}
  backup_and_link "$repo_root/nvim" "$config_home/nvim"
  backup_and_link "$repo_root/ghostty" "$config_home/ghostty"
}

setup_debugpy() {
  local data_home venv python
  data_home=${XDG_DATA_HOME:-$HOME/.local/share}
  venv="$data_home/nvim-dev-config/debugpy"
  python="$venv/bin/python"

  if [[ ! -x "$python" ]]; then
    log "creating isolated Debugpy environment"
    python3 -m venv "$venv"
  fi
  PIP_DISABLE_PIP_VERSION_CHECK=1 "$python" -m pip install \
    --quiet --upgrade --retries 3 --timeout 30 debugpy
}

setup_python_tools() {
  local data_home venv python tool
  data_home=${XDG_DATA_HOME:-$HOME/.local/share}
  venv="$data_home/nvim-dev-config/python-tools"
  python="$venv/bin/python"

  if [[ ! -x "$python" ]]; then
    log "creating isolated Python tools environment"
    python3 -m venv "$venv"
  fi
  PIP_DISABLE_PIP_VERSION_CHECK=1 "$python" -m pip install \
    --quiet --upgrade --retries 3 --timeout 30 basedpyright ruff
  for tool in basedpyright basedpyright-langserver ruff; do
    backup_and_link "$venv/bin/$tool" "$HOME/.local/bin/$tool"
  done
}
