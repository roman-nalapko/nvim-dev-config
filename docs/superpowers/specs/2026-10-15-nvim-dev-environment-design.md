# Portable Neovim Development Environment Design

## Intent

Create a pleasant learning and daily-development environment for a developer
moving from VS Code to Neovim on macOS and Debian. C and C++ are the primary
languages, with Pascal, assembly, and Python supported without turning Neovim
into an opaque distribution that is hard to understand or maintain.

## Experience

The editor uses a dark, modern palette close to VS Code Default Dark Modern,
Material-style file icons, and a transparent background. Ghostty provides the
actual window opacity and blur; Neovim remains usable in any capable terminal.
`<Space>` is the leader. Commands are grouped by intent and discoverable through
which-key, while a concise cheatsheet makes the initial learning path explicit.

The interface includes fuzzy finding, a file explorer, buffer navigation,
status and tab lines, Git signs, diagnostics, completion, snippets, formatting,
debugging, an embedded terminal, comments, pairs, and surround operations.

## Language tooling

C/C++ uses clangd, clang-format, CMake, and LLDB. Python uses basedpyright,
Ruff, and Debugpy. Pascal uses Free Pascal plus the best maintained compatible
language server available at implementation time, with compiler-based commands
as a documented fallback. Assembly uses NASM with Intel syntax and ELF64 as the
primary Debian x86-64 learning path. Apple Silicon uses a separate ARM64 path
through Clang and LLDB; the editor detects the host rather than treating object
formats and instruction sets as interchangeable.

## Portability and safety

The public repository contains Lua configuration, Ghostty configuration,
macOS and Debian bootstrap scripts, validation commands, and an English README.
Installers are non-destructive: they detect the OS, validate prerequisites,
back up conflicting user configuration, use bounded external operations, and
can be rerun. They never contain secrets or machine-specific absolute paths.
The README covers installation, updating, removal, troubleshooting, language
dependencies, and all custom mappings.

The result is published as the public GitHub repository `nvim-dev-config`.

## Non-goals

The project does not remove VS Code, replace the user's shell, require Ghostty,
or reproduce notebooks, containers, Kubernetes, Unity, or C# on the first pass.
It avoids broad framework-like abstractions and keeps plugin choices readable.

