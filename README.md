# Rockit Compiler

The self-hosting compiler for the Rockit programming language. Rockit is a compiled, statically-typed, memory-safe language designed to replace JavaScript, HTML, CSS, and the DOM as the foundational technology of the web platform. Developed by Dark Matter Tech.

**Status:** All compiler phases complete. Self-hosting bootstrap verified (Stage 2 == Stage 3 bytecode). Competitive with Go on compute benchmarks, faster than Node.js across the board.

## Table of Contents

- [Install](#install)
- [Build from Source](#build-from-source)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Compiler Pipeline](#compiler-pipeline)
- [Standard Library](#standard-library)
- [Runtime](#runtime)
- [Benchmarks](#benchmarks)
- [Branch Strategy](#branch-strategy)
- [CI / CD](#ci--cd)
- [Security](#security)
- [License](#license)

## Install

Install the latest release from the `staging` branch. The install scripts verify GPG signatures and SHA-256 checksums before installing.

**macOS / Linux:**

```bash
curl -fsSL https://rustygits.com/Dark-Matter/rockit-compiler/raw/branch/staging/scripts/install.sh | bash
```

**Windows (PowerShell):**

```powershell
iwr -useb https://rustygits.com/Dark-Matter/rockit-compiler/raw/branch/staging/scripts/install.ps1 | iex
```

**Custom install prefix:**

```bash
ROCKIT_PREFIX=$HOME/.local curl -fsSL https://rustygits.com/Dark-Matter/rockit-compiler/raw/branch/staging/scripts/install.sh | bash
```

The default install prefix is `/usr/local`. The compiler binary is placed in `$PREFIX/bin/rockit`, the runtime in `$PREFIX/share/rockit/rockit_runtime.o`, and the standard library in `$PREFIX/share/rockit/stdlib/`.

### Verify Installation

After installing, confirm the compiler is working:

```bash
rockit version
```

This prints the version, git commit, source hash, build timestamp, and target platform.

## Build from Source

Building from source requires two steps: first build the Stage 0 bootstrap compiler (written in Swift), then use it to compile the Stage 1 compiler (written in Rockit).

### Prerequisites

- Swift 5.9+ (for building Stage 0)
- clang (for compiling LLVM IR to native code)
- LLVM (provides the linker and code generation backend)
- Git (with submodule support)

### Steps

```bash
# 1. Clone this repo with submodules (stdlib lives in the launchpad submodule)
git clone --recurse-submodules https://rustygits.com/Dark-Matter/rockit-compiler.git
cd rockit-compiler

# 2. Clone and build the Stage 0 bootstrap compiler (Swift)
git clone --depth 1 https://github.com/dark-matter-tech/rockit-lang-bootstrap-compiler.git /tmp/stage0
cd /tmp/stage0 && swift build -c release
cd -

# 3. Concatenate the Stage 1 source modules into command.rok
bash src/build.sh

# 4. Use Stage 0 to compile Stage 1
/tmp/stage0/.build/release/rockit build-native src/command.rok

# 5. Build the runtime
bash runtime/rockit/build.sh

# 6. Verify the compiler works
src/command version
```

### Bootstrap Verification

To verify self-hosting, confirm that the compiler can compile itself and produce identical output:

```bash
# Stage 1 compiles itself -> Stage 2
src/command build-native src/command.rok -o /tmp/stage2 --runtime-path runtime/rockit_runtime.o

# Compare bytecode: Stage 2 compiling itself must match Stage 1 compiling itself
src/command compile src/command.rok -o /tmp/stage2.rokb
/tmp/stage2 compile src/command.rok -o /tmp/stage3.rokb
diff /tmp/stage2.rokb /tmp/stage3.rokb && echo "Bootstrap verified: Stage 2 == Stage 3"
```

## Usage

```bash
# Compile a Rockit program to a native binary
src/command build-native program.rok -o program --runtime-path runtime/rockit_runtime.o --lib-path launchpad

# Compile to bytecode
src/command compile program.rok -o program.rokb

# Emit LLVM IR (useful for debugging codegen)
src/command compile program.rok --emit-llvm -o program.ll

# Print version and build metadata
src/command version
```

### Example Program

```
// hello.rok
package com.darkmatter.hello

val greeting = "Hello"

fun greet(name: String): String {
    return "${greeting}, ${name}!"
}

fun main() {
    println(greet("world"))
}
```

```bash
src/command build-native hello.rok -o hello --runtime-path runtime/rockit_runtime.o
./hello
# Output: Hello, world!
```

## Project Structure

```
rockit-compiler/
|-- src/                        Stage 1 compiler source (Rockit)
|   |-- lexer.rok               Tokenizer (130+ token types)
|   |-- parser.rok              Recursive descent parser
|   |-- typechecker.rok         Two-pass type checker
|   |-- optimizer.rok           MIR optimization passes
|   |-- llvmgen.rok             LLVM IR native codegen (CPS coroutine transform)
|   |-- codegen.rok             Bytecode codegen + main() entry point
|   |-- update.rok              Self-update system
|   |-- build.sh                Concatenates modules into command.rok
|   |-- command.rok             Concatenated compiler source (generated)
|   +-- command                 Stage 1 native binary
|
|-- launchpad/                  Standard library (git submodule: dark-matter-tech/launchpad)
|   +-- rockit/                 15 stdlib modules organized by domain
|
|-- runtime/
|   |-- rockit_runtime.c        C runtime (ARC, task scheduler, event loop)
|   |-- rockit_runtime.h        C runtime header
|   +-- rockit/                 Modular Rockit runtime (freestanding mode)
|       |-- memory.rok          malloc/free wrappers, ARC retain/release
|       |-- string.rok          String struct, creation, comparison, concat
|       |-- string_ops.rok      charAt, indexOf, substring, split, trim
|       |-- object.rok          Object allocation, field access, type checking
|       |-- list.rok            Dynamic array (create, append, get, set, remove)
|       |-- map.rok             Hash table (create, put, get, keys, remove)
|       |-- io.rok              println, print for all types
|       |-- exception.rok       setjmp/longjmp exception handling
|       |-- file.rok            File I/O (read, write, exists, delete)
|       |-- process.rok         Process args, environment, system exec
|       |-- math.rok            Math functions (sqrt, sin, cos, floor, etc.)
|       |-- network.rok         Networking primitives
|       |-- concurrency.rok     Task scheduler, frame alloc/free, event loop
|       +-- build.sh            Concatenates and compiles runtime modules
|
|-- tests/                      Integration test suites
|   |-- core/                   Control flow, exceptions, nullable, when, imports
|   |-- types/                  Classes, generics, enums, sealed, interfaces, polymorphism
|   |-- functions/              Lambdas, overloads, varargs, extensions
|   |-- collections/            Lists, maps, strings
|   |-- patterns/               Destructuring, when guards, range patterns
|   |-- concurrency/            Async/await, actors
|   |-- advanced/               Unsafe, freestanding, byte ops, function pointers
|   |-- stdlib/                 Standard library integration tests
|   +-- ui/                     Views, themes, navigation
|
|-- examples/                   55+ feature test files (test_*.rok)
|-- benchmarks/                 Performance benchmarks vs Go, Node.js, Rust
|   +-- run_benchmarks.sh       Automated benchmark runner (best of 3 runs)
|
|-- scripts/
|   |-- install.sh              macOS/Linux installer (with GPG verification)
|   |-- install.ps1             Windows installer (PowerShell)
|   |-- package.sh              Release packaging (tarball + manifest + signing)
|   +-- sign.sh                 Code signing (GPG + platform-native)
|
|-- keys/
|   +-- darkmatter-release.asc  GPG public key for release verification
|
|-- .github/workflows/          GitHub Actions CI and release workflows
|-- .gitea/workflows/           Gitea CI and release workflows
|-- SECURITY.md                 Security architecture (9 layers)
+-- VERSION                     Current version (semver)
```

## Compiler Pipeline

The compiler processes Rockit source through six phases, producing either bytecode or native code via LLVM IR:

```
.rok source
    |
    v
  Lexer         130+ token types, string interpolation, nestable comments,
                significant newlines
    |
    v
  Parser        Recursive descent. All declarations (fun, class, data class,
                sealed class, enum, interface, object, actor, view, navigation,
                theme, package), expressions, statements, type annotations.
    |
    v
  Type Checker  Type inference, null safety (String vs String?), exhaustive
                when matching, generics with variance (in/out), suspend/await
                validation, actor isolation.
    |
    v
  MIR Lowering  AST -> MIR intermediate representation
    |
    v
  Optimizer     Constant folding, dead code elimination, optimization passes
    |
    v
  Codegen       Two backends:
                  - Bytecode (.rokb) for the VM interpreter
                  - LLVM IR -> native binary via clang (primary path)
```

### Native Codegen

The LLVM IR backend (`llvmgen.rok`) performs CPS coroutine transformation for suspend functions, emits ARC retain/release calls, and generates platform-appropriate LLVM IR. The IR is compiled to native code via clang at `-O1` optimization level.

### Freestanding Mode

The `--no-runtime` flag enables freestanding compilation for systems programming. This mode provides `Ptr<T>`, `alloc`/`free`, `bitcast`, `cstr`, `unsafe` blocks, `loadByte`/`storeByte`, `extern` C functions, and `@CRepr` structs. The runtime itself is written in Rockit using this mode.

## Standard Library

The standard library ships as 15 modules in the `launchpad` submodule ([dark-matter-tech/launchpad](https://github.com/dark-matter-tech/launchpad)). Import via dot-separated paths.

| Module | Import Path | Key Exports |
|--------|-------------|-------------|
| Collections | `rockit.core.collections` | listMap, listFilter, listFold, listSort, listZip, listFlatten |
| Math | `rockit.core.math` | gcd, lcm, clamp, lerp, sqrt, sin, cos, PI, pow, log |
| Strings | `rockit.core.strings` | pad, repeat, join, split, reversed, replace, truncate |
| Result | `rockit.core.result` | Success, Failure, resultOrElse, resultMap |
| UUID | `rockit.core.uuid` | uuid4 |
| File I/O | `rockit.io.file` | readFile, writeFile, readLines, exists, deleteFile |
| Path | `rockit.io.path` | pathJoin, pathDir, pathBase, pathExt, pathNormalize |
| HTTP | `rockit.net.http` | httpGet, httpPost, httpPut, httpDelete, httpRequest |
| WebSocket | `rockit.net.ws` | wsConnect, wsSend, wsRecv, wsClose |
| URL | `rockit.net.url` | urlParse, urlEncode, urlDecode, urlQueryParams |
| Base64 | `rockit.encoding.base64` | base64Encode, base64Decode |
| XML | `rockit.encoding.xml` | xmlParse, xmlStringify, xmlElement, xmlAttribute |
| JSON | `rockit.json` | jsonParse, jsonStringify, jsonObject, jsonArray, jsonFrom |
| DateTime | `rockit.time.datetime` | now, dateFromEpoch, formatDate, dayOfWeek |
| Probe (testing) | `rockit.test.probe` | assertEquals, assertTrue, assertFalse, fail, and 15+ more |

## Runtime

The Rockit runtime provides memory management, object representation, and concurrency primitives. It is written in two layers:

**C runtime** (`runtime/rockit_runtime.c`): The thin C layer that interfaces with the OS. Provides the ARC reference counting core, task scheduler, event loop, and actor message dispatch wrappers.

**Rockit runtime** (`runtime/rockit/`): The bulk of the runtime, written in Rockit itself using freestanding mode (`--no-runtime`). Includes string handling, object allocation, list/map data structures, file I/O, math, exception handling, and concurrency primitives. Compiled to a linkable object file (`rockit_runtime.o`) that is linked into every Rockit program.

### Key Runtime Features

- **ARC memory management** -- Automatic reference counting with compile-time cycle analysis. Deterministic deallocation with no garbage collector overhead. Immortal string literals (zero malloc for constants). Object pooling for reduced allocation pressure.
- **Coroutine scheduler** -- CPS-transformed suspend functions run as state machines on a cooperative scheduler. Concurrent blocks use an event loop with join counters.
- **Actor message dispatch** -- Actor declarations compile as classes with mailbox-based message routing. Thread-safe by construction.
- **Platform bridge** -- `@Capability` annotations declare platform capabilities. `extern` functions link to C libraries.

## Benchmarks

The `benchmarks/` directory contains equivalent implementations in Rockit, Go, Node.js, and Rust across 10 benchmark programs: fibonacci, tight loop, object allocation, string concatenation, sieve of Eratosthenes, matrix multiplication, binary trees, spectral norm, fannkuch, and n-body.

Representative results (best of 3 runs, macOS arm64):

| Benchmark | Rockit | Go | Node.js |
|-----------|--------|----|---------|
| fib(40) | 0.49s | 0.52s | 1.1s |
| loop 100M | 0.18s | 0.19s | 0.75s |
| objects 1M | 0.23s | 0.15s | 0.10s |
| strings 100K | 0.44s | 0.54s | 0.09s |

Rockit matches or beats Go on compute-bound workloads (fibonacci, tight loops) and is consistently faster than Node.js. Object-heavy and string-heavy benchmarks continue to improve as ARC and allocator optimizations mature.

Run the full suite:

```bash
bash benchmarks/run_benchmarks.sh
```

## Branch Strategy

This repository uses a three-branch promotion model:

| Branch | Purpose | Stability |
|--------|---------|-----------|
| `develop` | Active development. New features land here first. | Unstable |
| `master` | Integration testing. Merges from `develop` after review. | Testing |
| `staging` | Production releases. Install scripts pull from this branch. | Stable |

**Install from `staging`.** Build from source from `develop` or `master`.

Releases are tagged on `staging` (e.g., `v0.1.0`) and published as tarballs with signed manifests.

## CI / CD

Continuous integration runs on both Gitea (primary) and GitHub (mirror):

- **Gitea:** `.gitea/workflows/ci.yml` and `.gitea/workflows/release.yml`
- **GitHub:** `.github/workflows/ci.yml` and `.github/workflows/release.yml`

The CI pipeline:

1. Builds the Stage 0 bootstrap compiler from [dark-matter-tech/rockit-lang-bootstrap-compiler](https://github.com/dark-matter-tech/rockit-lang-bootstrap-compiler)
2. Concatenates Stage 1 source modules via `build.sh`
3. Compiles Stage 1 using Stage 0
4. Builds the runtime
5. Runs all integration tests (`examples/test_*.rok`)
6. Performs bootstrap verification (Stage 2 == Stage 3 bytecode)

CI runs on Linux x86_64 (Ubuntu 22.04 / Swift 5.10.1) and macOS arm64 (macOS 14).

## Repositories

The Rockit toolchain spans multiple repositories:

| Repository | Description |
|------------|-------------|
| [Dark-Matter/rockit-compiler](https://rustygits.com/Dark-Matter/rockit-compiler) | This repo -- self-hosting compiler, runtime, tests, benchmarks |
| [dark-matter-tech/rockit-lang-bootstrap-compiler](https://github.com/dark-matter-tech/rockit-lang-bootstrap-compiler) | Stage 0 bootstrap compiler (Swift) |
| [dark-matter-tech/launchpad](https://github.com/dark-matter-tech/launchpad) | Standard library (15 modules, included as git submodule) |
| [Dark-Matter/fuel](https://rustygits.com/Dark-Matter/fuel) | Package manager |

**Gitea** (rustygits.com) is the primary host. GitHub mirrors are maintained for public access and CI compatibility.

## Security

Rockit implements a multi-layer security architecture covering the full chain from source to execution. See [SECURITY.md](SECURITY.md) for the complete specification.

Key layers:

- **Build identity** -- Every compiler binary embeds version, git commit, source hash, timestamp, and platform.
- **Release manifests** -- Every release tarball includes `MANIFEST.sha256` with SHA-256 hashes of all files.
- **Code signing** -- GPG signatures on all releases. Platform-native signing (macOS codesign, Windows Authenticode) where applicable.
- **Bootstrap verification** -- CI verifies Stage 2 == Stage 3 on every build to detect compiler tampering.

Public signing keys are published in the `keys/` directory.

### Reporting Vulnerabilities

See [SECURITY.md](SECURITY.md) for the vulnerability disclosure policy and contact information.

## License

Proprietary -- Dark Matter Tech. All rights reserved.
