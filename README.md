# nvim-dev-config

A readable Neovim 0.12+ environment for learning and daily development on
macOS Apple Silicon and Debian x86-64. C and C++ are the primary workflow;
Python, Free Pascal, and assembly are supported without hiding the setup behind
a large Neovim distribution.

The visual style is based on Tokyo Night with a transparent editor background.
Ghostty provides the actual window opacity and blur. **Ghostty is optional**:
Neovim continues to work in Terminal.app and other capable terminals.

## Architecture and design

- **Small, readable modules:** `init.lua` only checks the Neovim version and
  loads the configuration. Options, keymaps, language definitions, build
  helpers, and plugin groups live in separate Lua modules.
- **Reproducible plugins:** `lazy-lock.json` is committed. Updates restore this
  lock instead of silently selecting newer plugin revisions.
- **User-local tools:** standalone binaries and isolated Python environments
  live below `~/.local`; the scripts never write to `/usr/local/bin`.
- **Safe configuration links:** existing Neovim or Ghostty configuration is
  timestamped and preserved before a managed symlink is created.
- **Explicit platform boundary:** installers fail before making changes on an
  unsupported operating system or CPU architecture.

| Platform | Architecture | Assembly workflow | Terminal |
| --- | --- | --- | --- |
| macOS | Apple Silicon (`arm64`) | Clang, ARM64 `.s` | Ghostty via Homebrew |
| Debian | x86-64 | NASM, Intel syntax, ELF64 | Ghostty when available from configured APT repositories |

Ubuntu and Debian ARM64 are not currently supported by the bootstrap scripts.
The Lua configuration may work there, but package installation has not been
implemented or tested.

## Requirements

- macOS on Apple Silicon with [Homebrew](https://brew.sh), or Debian x86-64.
- Git and an internet connection for the first installation.
- `~/.local/bin` in `PATH` on Debian.
- Neovim 0.12 or newer. The installers provide a compatible version.

## Quick start

```bash
git clone https://github.com/roman-nalapko/nvim-dev-config.git
cd nvim-dev-config
./scripts/install.sh
nvim
```

The first Neovim start downloads plugins with `lazy.nvim` and installs the
configured Treesitter parsers. Run `:Lazy` to inspect progress, then
`:checkhealth` if anything is unavailable.

To link only the configuration and skip all packages:

```bash
./scripts/install.sh --config-only
```

## macOS

The installer uses Homebrew for Neovim, Ghostty, Git, CMake, Ninja, LLVM,
standalone LLDB, a PATH-visible clang-format, Free Pascal, NASM, ripgrep, fd,
ShellCheck, basedpyright, Ruff, StyLua, Tree-sitter CLI, Python, and
JetBrainsMono Nerd Font. Debugpy is
installed in an isolated environment under
`~/.local/share/nvim-dev-config/debugpy`.

```bash
./scripts/install-macos.sh
```

After installation, start Ghostty from Applications and run `nvim`. The
Ghostty configuration uses 86% opacity and blur. macOS assembly files use
ARM64 syntax in `.s` files and are built through Clang/LLDB.

## Debian x86-64

The Debian installer uses APT for compilers and developer tools, then installs
the current official Neovim x86-64 release and a checksum-verified Tree-sitter
CLI under `~/.local/opt`. This avoids the older Neovim versions present in some
Debian releases and supplies the parser compiler required by this setup. It
also installs a checksum-verified JetBrainsMono Nerd Font in the user's local
font directory so Neovim icons render correctly. Basedpyright and Ruff are
installed into an isolated Python environment and linked through
`~/.local/bin`; project environments remain untouched.
StyLua is installed as a checksum-verified standalone binary in
`~/.local/opt`.
If Debian's LLVM package exposes only a versioned debugger adapter, the
installer selects the newest `lldb-dap` or `lldb-vscode` candidate and creates
`~/.local/bin/lldb-dap`. It never needs a system-wide symlink.

```bash
sudo apt update
sudo apt install git
git clone https://github.com/roman-nalapko/nvim-dev-config.git
cd nvim-dev-config
./scripts/install-debian.sh
```

Ghostty is installed only when it exists in the configured Debian repository.
The Ghostty project currently does not publish official Linux binaries; its
[Linux installation page](https://ghostty.org/docs/install/binary) documents
distribution packages, community `.deb` builds, and AppImage alternatives.
The script deliberately does not execute an unaudited third-party `curl | sh`
installer.

Debian assembly uses NASM, Intel syntax, and ELF64. The laptop target for this
configuration is x86-64.

## What the installer changes

- Installs the platform packages listed by `scripts/install-*.sh --print-packages`.
- Creates `~/.config/nvim` and `~/.config/ghostty` as symlinks to this clone.
- Moves a conflicting real path or wrong symlink to a sibling path containing
  `.backup-YYYYMMDD-HHMMSS` before linking.
- Keeps a correct existing symlink unchanged, so repeated runs are idempotent.
- Creates a dedicated Debugpy Python environment; it does not modify project
  environments or install Python packages globally.
- Does not remove VS Code, replace the shell, or store credentials.

Inspect the environment at any time:

```bash
./scripts/healthcheck.sh
```

Use `--strict` when automation should fail if Neovim or Git is missing.

## Language support

### C and C++

- clangd diagnostics, navigation, refactoring, and completion.
- clang-format on save.
- CMake/Make detection; single files fall back to Clang with debug symbols.
- Project run commands ask for the produced executable because CMake and Make
  targets do not have to match the current source filename.
- LLDB-DAP debugging through `nvim-dap`.

### Python

- basedpyright for type information and Ruff for linting/formatting.
- Debugpy for debugging.
- Current-file execution and pytest mappings.

### Free Pascal

- Free Pascal (`fpc`) compilation with debug information.
- Native Vim Pascal syntax is the dependable fallback.
- Optional `pasls` support is enabled automatically when the executable is on
  `PATH`. Building `pasls` currently requires Lazarus sources and is intentionally
  not performed by the bootstrap script; see
  [genericptr/pascal-language-server](https://github.com/genericptr/pascal-language-server).

### Assembly

- Debian: NASM, Intel syntax, ELF64, GCC linking, and LLDB.
- Apple Silicon: ARM64 `.s` sources assembled and linked by Clang, then LLDB.
- The two targets intentionally use separate fixtures and build commands.

## Essential keymaps

`<leader>` is the Space key. Press Space and pause briefly to open which-key.
Mappings under `<leader>l` are local to the current language and appear only
for supported file types.

| Group | Key | Action |
| --- | --- | --- |
| Modes | `i` / `<Esc>` | Enter Insert mode / return to Normal mode |
| Editing | `<C-s>` | Save from Normal, Insert, or Visual mode |
| Editing | `u` / `<C-r>` | Undo / redo |
| Editing | `yy` / `dd` / `p` | Copy line / delete line / paste |
| Navigation | `h j k l` | Move left, down, up, right |
| Navigation | `w` / `b` | Next / previous word |
| Navigation | `gg` / `G` | First / last line |
| Navigation | `<C-d>` / `<C-u>` | Half-page down / up |
| Files | `<leader>e` | Toggle file explorer |
| Find | `<leader>ff` / `<leader>fg` | Find files / search project text |
| Find | `<leader>fb` / `<leader>fr` | Find buffers / recent files |
| Buffers | `]b` / `[b` | Next / previous buffer |
| Buffers | `<leader>bd` | Delete current buffer |
| Windows | `<leader>sv` / `<leader>sh` | Vertical / horizontal split |
| Windows | `<C-h/j/k/l>` | Focus the window in that direction |
| LSP | `gd` / `gr` / `K` | Definition / references / documentation |
| LSP | `<leader>cf` | Format buffer or selection |
| LSP | `<leader>cr` / `<leader>ca` | Rename symbol / code action |
| Diagnostics | `[d` / `]d` | Previous / next diagnostic |
| Build | `<leader>lb` | Build current language target; run Python file |
| Run | `<leader>lr` | Run compiled C/C++/Pascal/ASM target |
| Test | `<leader>lt` | Run pytest for the current Python file |
| Debug | `<F5>` / `<F10>` / `<F11>` / `<F12>` | Continue / step over / into / out |
| Debug | `<leader>db` / `<leader>du` / `<leader>dr` | Breakpoint / debug UI / REPL |
| Git | `<leader>gg` | Open Fugitive Git status |
| Git | `]h` / `[h` | Next / previous changed hunk |
| Git | `<leader>gp` / `<leader>gs` / `<leader>gr` | Preview / stage / reset hunk |
| Terminal | `<leader>tt` / `<leader>th` | Floating / horizontal terminal |
| Terminal | `<C-\>` / `<Esc><Esc>` | Toggle terminal / leave Terminal mode |

The complete reference, including Vim's native commands and a suggested
learning order, is in [docs/KEYMAPS.md](docs/KEYMAPS.md).

## Updating

```bash
./scripts/update.sh
```

The updater requires a clean Git working tree, pulls with `--ff-only`, refreshes
the managed configuration links, restores the committed plugin lock, installs
missing Treesitter parsers, updates installed parsers, and runs the strict
healthcheck. It does not upgrade APT or Homebrew packages by default.

Preview every command without changing anything:

```bash
./scripts/update.sh --dry-run
```

Re-run the platform package installer as part of the update when you explicitly
want dependency upgrades:

```bash
./scripts/update.sh --with-packages
```

Inside Neovim, `:Lazy` shows plugin state. `:TSUpdate` remains available for a
manual parser update.

## Repository layout

```text
.
├── ghostty/config.ghostty      # opacity, blur, font, and terminal key bindings
├── nvim/
│   ├── init.lua               # version gate and configuration entry point
│   ├── after/ftplugin/        # language-specific build and run mappings
│   └── lua/
│       ├── config/            # editor, language, build, and parser modules
│       └── plugins/           # focused lazy.nvim plugin specifications
├── scripts/
│   ├── install.sh             # platform router
│   ├── install-macos.sh
│   ├── install-debian.sh
│   ├── update.sh              # safe repository and runtime lifecycle
│   └── healthcheck.sh         # read-only environment report
├── tests/                     # shell, Neovim, docs, and toolchain checks
└── docs/KEYMAPS.md            # keymap reference and Vim survival guide
```

## Uninstall and restore

The repository never deletes backups automatically. Remove only managed
symlinks, then move the backup you want back into place:

```bash
test -L ~/.config/nvim && unlink ~/.config/nvim
test -L ~/.config/ghostty && unlink ~/.config/ghostty

# Example — choose the actual timestamped directory first:
mv ~/.config/nvim.backup-YYYYMMDD-HHMMSS ~/.config/nvim
mv ~/.config/ghostty.backup-YYYYMMDD-HHMMSS ~/.config/ghostty
```

Homebrew/APT packages and Neovim plugin data are left installed deliberately.
Remove them manually only after checking that no other workflow uses them.

## Troubleshooting

- Run `./scripts/healthcheck.sh`, then `nvim` and `:checkhealth`.
- Run `:Lazy` when a plugin command is unavailable.
- Run `:LspInfo` and confirm the language server executable is on `PATH`.
- Generate `compile_commands.json` for non-trivial CMake C/C++ projects.
- On Debian, ensure `~/.local/bin` precedes an old system Neovim in `PATH`.
- Debian calls the `fd-find` executable `fdfind`; the installer creates a
  user-local `fd` link when necessary.
- Basedpyright needs both `basedpyright` and `basedpyright-langserver`; both are
  linked from the isolated tools environment.
- If LLDB debugging is missing on Debian, run
  `find /usr/lib -path '*/bin/lldb-dap' -type f 2>/dev/null` and then re-run the
  installer. `healthcheck.sh` also recognizes versioned LLVM paths directly.
- If parser installation reports that `tree-sitter` is missing, confirm
  `~/.local/bin/tree-sitter --version` works and that `~/.local/bin` is in
  `PATH`.
- If transparency is missing, restart Ghostty completely; Ghostty documents
  that opacity changes on macOS require a restart.
- Pascal compiler support works without `pasls`; LSP features do not.

See [docs/KEYMAPS.md](docs/KEYMAPS.md) for the complete custom keymap and a
short Vim survival guide.

## Development checks

```bash
make test
shellcheck scripts/*.sh tests/*.sh
```

The suite verifies installer safety/idempotency, headless Neovim behavior, and
real compilation of every toolchain available on the current host.

## License

MIT — see [LICENSE](LICENSE).
