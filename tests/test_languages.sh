#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fixture_dir="$repo_root/tests/fixtures"
build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

count=0
pass() { count=$((count + 1)); printf 'ok %d - %s\n' "$count" "$1"; }
skip() { count=$((count + 1)); printf 'ok %d - %s # SKIP %s\n' "$count" "$1" "$2"; }

clang -std=c17 -Wall -Wextra -Werror "$fixture_dir/hello.c" -o "$build_dir/hello-c"
"$build_dir/hello-c" >/dev/null
pass 'C fixture compiles and runs'

clang++ -std=c++20 -Wall -Wextra -Werror "$fixture_dir/hello.cpp" -o "$build_dir/hello-cpp"
"$build_dir/hello-cpp" >/dev/null
pass 'C++ fixture compiles and runs'

PYTHONPYCACHEPREFIX="$build_dir/pycache" python3 -m py_compile "$fixture_dir/hello.py"
pass 'Python fixture compiles'

if command -v fpc >/dev/null 2>&1; then
  fpc -FE"$build_dir" -FU"$build_dir" -ohello-pas "$fixture_dir/hello.pas" >/dev/null
  "$build_dir/hello-pas" >/dev/null
  pass 'Pascal fixture compiles and runs'
else
  skip 'Pascal fixture' 'fpc is not installed'
fi

case "$(uname -s)" in
  Darwin)
    clang -g "$fixture_dir/hello-arm64.s" -o "$build_dir/hello-asm"
    "$build_dir/hello-asm"
    pass 'ARM64 assembly fixture compiles and runs'
    ;;
  Linux)
    if command -v nasm >/dev/null 2>&1; then
      nasm -f elf64 -g -F dwarf "$fixture_dir/hello-x86_64.asm" -o "$build_dir/hello-asm.o"
      cc -g -no-pie "$build_dir/hello-asm.o" -o "$build_dir/hello-asm"
      "$build_dir/hello-asm"
      pass 'x86-64 NASM fixture compiles and runs'
    else
      skip 'x86-64 assembly fixture' 'nasm is not installed'
    fi
    ;;
  *)
    skip 'assembly fixture' 'unsupported test host'
    ;;
esac

printf '1..%d\n' "$count"
