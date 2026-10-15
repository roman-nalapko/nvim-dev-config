#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readme="$repo_root/README.md"
keymaps="$repo_root/docs/KEYMAPS.md"

fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }

[[ -f "$readme" ]] || fail 'README.md is missing'
[[ -f "$keymaps" ]] || fail 'docs/KEYMAPS.md is missing'
[[ -f "$repo_root/LICENSE" ]] || fail 'LICENSE is missing'

for section in \
  'Requirements' 'Quick start' 'macOS' 'Debian x86-64' \
  'What the installer changes' 'Language support' 'Updating' \
  'Uninstall and restore' 'Troubleshooting'; do
  rg -Fq "## $section" "$readme" || fail "README section missing: $section"
done

for phrase in 'Ghostty is optional' 'backup-' 'Free Pascal' 'NASM' 'ARM64' 'CMake' 'Debugpy'; do
  rg -Fq "$phrase" "$readme" || fail "README contract missing: $phrase"
done

for group in 'Basics' 'Navigation' 'Find' 'Buffers' 'Windows' 'LSP and diagnostics' \
  'Build and run' 'Debugging' 'Git' 'Terminal'; do
  rg -Fq "## $group" "$keymaps" || fail "keymap group missing: $group"
done

for mapping in \
  '<leader>e' '<leader>ff' '<leader>fg' '<leader>fb' '<leader>fh' '<leader>fr' \
  '<leader>q' '<leader>sv' '<leader>sh' '<leader>bd' '<leader>cf' '<leader>cr' \
  '<leader>ca' '<leader>lb' '<leader>lr' '<leader>lt' '<leader>db' '<leader>du' \
  '<leader>dr' '<leader>gg' '<leader>gp' '<leader>gs' '<leader>gr' '<leader>gb' \
  '<leader>tt' '<leader>th'; do
  rg -Fq "$mapping" "$keymaps" || fail "undocumented mapping: $mapping"
done

printf 'ok - documentation contract\n'
