# Rockit Compiler

The Rockit language compiler. Self-hosting — Rockit compiles itself.

> **Status:** All phases complete. Self-hosting bootstrap verified (Stage 2 == Stage 3).

## Install

**macOS / Linux:**
```bash
curl -fsSL https://rustygits.com/Dark-Matter/rockit-compiler/raw/branch/master/scripts/install.sh | bash
```

**Windows (PowerShell):**
```powershell
iwr -useb https://rustygits.com/Dark-Matter/rockit-compiler/raw/branch/master/scripts/install.ps1 | iex
```

## Build from Source

Requires Swift 5.9+ and clang for the initial bootstrap (Stage 0 lives in [Dark-Matter/moon](https://rustygits.com/Dark-Matter/moon)).

```bash
# After Stage 1 binary is available:
src/command build-native src/command.rok
src/command version
```

## Structure

```
src/            Stage 1 compiler source (.rok)
launchpad/      Standard library (git submodule)
runtime/        C and Rockit runtime
scripts/        Install, package, and signing scripts
tests/          Integration test suites
examples/       Feature test files
benchmarks/     Performance benchmarks
keys/           Public signing keys
```

## License

Proprietary — Dark Matter Tech
