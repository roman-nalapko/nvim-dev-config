# Keymaps and first-week cheatsheet

`<leader>` is the Space key. Press Space and pause briefly to open which-key.
Mappings under `<leader>l` are local to the current language and appear only in
the relevant file type.

## Basics

| Key | Action |
| --- | --- |
| `i` | Enter Insert mode |
| `<Esc>` | Return to Normal mode / clear search highlight |
| `<C-s>` | Save from Normal, Insert, or Visual mode |
| `<leader>q` | Quit the current window with confirmation |
| `u` / `<C-r>` | Undo / redo |
| `yy` / `dd` / `p` | Copy line / delete line / paste |
| `v`, `V`, `<C-v>` | Character, line, and block Visual modes |
| `.` | Repeat the last change |

## Navigation

| Key | Action |
| --- | --- |
| `h j k l` | Left, down, up, right |
| `w` / `b` | Next / previous word |
| `0` / `^` / `$` | Line start / first text / line end |
| `gg` / `G` | First / last line |
| `<C-d>` / `<C-u>` | Half-page down / up |
| `gd` / `gD` | LSP definition / declaration |
| `gr` | LSP references |
| `K` | LSP hover documentation |

## Find

| Key | Action |
| --- | --- |
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Find text with ripgrep |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Search help |
| `<leader>fr` | Recent files |
| `/text` | Search forward in the current file |
| `n` / `N` | Next / previous search result |

## Buffers

| Key | Action |
| --- | --- |
| `]b` / `[b` | Next / previous buffer |
| `<leader>bd` | Delete current buffer |

## Windows

| Key | Action |
| --- | --- |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<C-h/j/k/l>` | Focus the window in that direction |

## LSP and diagnostics

| Key | Action |
| --- | --- |
| `<leader>cf` | Format buffer or selection |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cd` | Diagnostics for current line |
| `[d` / `]d` | Previous / next diagnostic |

## Build and run

These are buffer-local and depend on the file type.

| Key | Action |
| --- | --- |
| `<leader>lb` | Build C/C++/Pascal/ASM; run current Python file |
| `<leader>lr` | Run the C/C++/Pascal/ASM executable |
| `<leader>lt` | Run pytest for the current Python file |

C/C++ selects CMake, Make, or a single-file Clang command. Debian ASM uses
NASM/ELF64; macOS ASM uses Clang/ARM64.

## Debugging

| Key | Action |
| --- | --- |
| `<F5>` | Start or continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>db` | Toggle breakpoint |
| `<leader>du` | Toggle debug UI |
| `<leader>dr` | Open debug REPL |

## Git

Git hunk mappings appear after gitsigns attaches to a tracked file.

| Key | Action |
| --- | --- |
| `<leader>gg` | Fugitive Git status |
| `]h` / `[h` | Next / previous changed hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gb` | Blame current line |

## Terminal

| Key | Action |
| --- | --- |
| `<leader>tt` | Floating terminal |
| `<leader>th` | Horizontal terminal |
| `<C-\>` | Toggle terminal |
| `<Esc><Esc>` | Leave Terminal mode |

## Suggested learning order

1. Spend two days on Normal/Insert mode, movement, `yy`, `dd`, `p`, `u`, and `.`.
2. Add search, Visual mode, and text objects such as `ciw`, `di(`, and `va{`.
3. Learn buffers and splits before adding tabs to the workflow.
4. Use which-key instead of memorizing the complete table at once.
5. Run `:Tutor` when the core motions still feel unfamiliar.
