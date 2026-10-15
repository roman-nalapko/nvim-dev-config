# nvim-dev-config

A readable Neovim 0.12+ environment for learning and daily development on
macOS Apple Silicon and Debian x86-64. C and C++ are the primary workflow;
Python, Free Pascal, and assembly are supported without hiding the setup behind
a large Neovim distribution.

The visual style is based on Tokyo Night with a transparent editor background.
Ghostty provides the actual window opacity and blur. **Ghostty is optional**:
Neovim continues to work in Terminal.app and other capable terminals.

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
standalone LLDB, Free Pascal, NASM, ripgrep, fd, ShellCheck, basedpyright,
Ruff, StyLua, Tree-sitter CLI, Python, and JetBrainsMono Nerd Font. Debugpy is
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
font directory so Neovim icons render correctly.

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

## Updating

```bash
git pull --ff-only
./scripts/install.sh --config-only
nvim --headless "+Lazy! sync" +qa
```

Inside Neovim, use `:Lazy sync` for plugins and `:TSUpdate` for parsers.
Review upstream breaking changes before changing the minimum Neovim version.

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
