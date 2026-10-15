# Neovim Development Environment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build, install, validate, and publish a portable Neovim and Ghostty development environment for macOS and Debian.

**Architecture:** A small Lua configuration loads focused modules and declarative plugin specs through lazy.nvim. Shell installers own OS dependency setup and safe symlink deployment; executable smoke tests validate repository structure, shell safety, and headless Neovim startup.

**Tech Stack:** Neovim Lua, lazy.nvim, Bash, Ghostty configuration, Homebrew, APT, shellcheck, GitHub CLI.

**Spec:** `docs/superpowers/specs/2026-10-15-nvim-dev-environment-design.md`

## Global Constraints

- Support current macOS on Apple Silicon and Debian stable/testing.
- Treat Ghostty as recommended but optional.
- Back up conflicting user configuration before deployment.
- Never store secrets or machine-specific absolute paths.
- Optimize the default workflow for C/C++, then Python, Pascal, and assembly.
- Use NASM/Intel syntax/ELF64 for Debian x86-64 and Clang/LLDB for macOS ARM64.
- Publish the result as the public GitHub repository `nvim-dev-config`.
- Keep configuration readable enough for a new Neovim user to learn from it.

## Review Focus

- Existing real directories and symlinks must not be overwritten silently.
- A second installer run must be idempotent and must not create needless backups.
- Network or package-manager failure must stop with a useful error.
- Unsupported OS or Debian derivatives must fail before changing user files.
- Neovim must start when Ghostty is absent and when optional language tools are absent.

---

### Task 1: Repository skeleton and safety tests

**Files:**
- Create: `Makefile`
- Create: `tests/test_repo.sh`
- Create: `scripts/lib.sh`
- Create: `scripts/install.sh`

**Interfaces:**
- Produces: `backup_and_link(source, target)` and `detect_platform()` shell functions.

- [ ] Write repository and installer tests covering missing sources, real-directory backup, correct symlink, repeated run, and unsupported OS.
- [ ] Run `bash tests/test_repo.sh`; expect failure because installer functions are absent.
- [ ] Implement the minimal shared shell functions and installer entry point.
- [ ] Run `bash tests/test_repo.sh`; expect all assertions to pass.
- [ ] Commit the repository skeleton and safety behavior.

### Task 2: Neovim core and UI

**Files:**
- Create: `nvim/init.lua`
- Create: `nvim/lua/config/{options,keymaps,autocmds,lazy}.lua`
- Create: `nvim/lua/plugins/{ui,editor,treesitter}.lua`
- Create: `tests/nvim_smoke.lua`

**Interfaces:**
- Consumes: deployment layout from Task 1.
- Produces: `require("config.*")` modules and lazy.nvim plugin specifications.

- [ ] Extend static tests to require every Lua module and assert leader, transparency, and core mappings.
- [ ] Run tests; expect missing-module failures.
- [ ] Implement core options, discoverable mappings, transparent dark UI, navigation, search, explorer, syntax, and editing plugins.
- [ ] Run Lua/static tests, then `nvim --headless "+lua dofile('tests/nvim_smoke.lua')" +qa`; expect clean exit.
- [ ] Commit the working editor core.

### Task 3: Language, build, Git, and debugging workflows

**Files:**
- Create: `nvim/lua/plugins/{coding,lsp,formatting,debug,git}.lua`
- Create: `nvim/after/ftplugin/{c,cpp,python,pascal,asm}.lua`
- Modify: `tests/nvim_smoke.lua`

**Interfaces:**
- Consumes: plugin loader and mapping conventions from Task 2.
- Produces: LSP/completion/format/debug commands and language-local build mappings.

- [ ] Add smoke assertions for plugin specs, LSP server names, formatter mappings, and all four language families.
- [ ] Run headless tests; expect missing workflow failures.
- [ ] Implement clangd/LLDB/CMake, basedpyright/Ruff/Debugpy, Free Pascal tooling fallback, Debian NASM/ELF64 and macOS ARM64 commands, Git signs, completion, formatting, and DAP UI.
- [ ] Run headless tests and language fixture compile checks for each locally available tool; expect success or an explicit SKIP for optional tools.
- [ ] Commit language workflows.

### Task 4: Ghostty and cross-platform bootstrap

**Files:**
- Create: `ghostty/config.ghostty`
- Create: `scripts/install-macos.sh`
- Create: `scripts/install-debian.sh`
- Create: `scripts/healthcheck.sh`
- Modify: `tests/test_repo.sh`

**Interfaces:**
- Consumes: Task 1 shell library and Neovim/Ghostty source directories.
- Produces: repeatable platform installers and a read-only health report.

- [ ] Add tests for platform routing, package manifests, Ghostty opacity, and read-only health checks.
- [ ] Run shell tests; expect failures for absent scripts/config.
- [ ] Implement Homebrew and APT package setup with clear failure boundaries, then link configs safely.
- [ ] Run `shellcheck scripts/*.sh`, shell tests, and healthcheck; expect clean results apart from labelled missing optional tools.
- [ ] Commit cross-platform installation.

### Task 5: Documentation, installation, and publication

**Files:**
- Create: `README.md`
- Create: `docs/KEYMAPS.md`
- Create: `LICENSE`
- Modify: `Makefile`

**Interfaces:**
- Consumes: every supported command and mapping from Tasks 1–4.
- Produces: end-user install/update/remove/troubleshooting documentation.

- [ ] Add documentation checks for macOS, Debian, backup behavior, Ghostty optionality, all language toolchains, and every custom mapping group.
- [ ] Run documentation checks; expect failure until the documents exist.
- [ ] Write English documentation and MIT license.
- [ ] Install dependencies and deploy on this Mac, run all tests plus headless startup, and audit the final diff for secrets and absolute user paths.
- [ ] Initialize Git history, create a public GitHub repository named `nvim-dev-config`, push the default branch, and verify the remote README.

