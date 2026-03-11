#!/bin/bash
# build.sh — Build the Rockit runtime
#
# Strategy: Use the C runtime (rockit_runtime.c) which is the reference
# implementation. The self-hosted Rockit runtime (.rok modules) is the
# long-term target but currently has a codegen issue in --no-runtime mode
# that corrupts processArgs string handling.
#
# Set ROCKIT_RUNTIME=rok to force the self-hosted runtime path.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_DIR="$SCRIPT_DIR/.."
cd "$SCRIPT_DIR"

RUNTIME_MODE="${ROCKIT_RUNTIME:-c}"

if [ "$RUNTIME_MODE" = "rok" ]; then
    # ── Self-hosted Rockit runtime ──────────────────────────────────
    COMMAND="$SCRIPT_DIR/../../src/command"
    if [ ! -f "$COMMAND" ]; then
        echo "Error: Stage 1 compiler not found at $COMMAND"
        exit 1
    fi

    cat \
        math.rok \
        memory.rok \
        string.rok \
        string_ops.rok \
        object.rok \
        list.rok \
        map.rok \
        io.rok \
        exception.rok \
        file.rok \
        process.rok \
        network.rok \
        concurrency.rok \
        > rockit_runtime.rok

    echo "Concatenated runtime → rockit_runtime.rok"

    "$COMMAND" compile rockit_runtime.rok --emit-llvm --no-runtime -o rockit_runtime.ll

    echo "Generated rockit_runtime.ll"

    clang -c -O1 -w rockit_runtime.ll -o rockit_runtime.o
else
    # ── C runtime (reference implementation) ────────────────────────
    C_SRC="$RUNTIME_DIR/rockit_runtime.c"
    if [ ! -f "$C_SRC" ]; then
        echo "Error: C runtime not found at $C_SRC"
        exit 1
    fi

    # Detect OpenSSL include path
    SSL_INCLUDE=""
    if command -v brew >/dev/null 2>&1; then
        SSL_PREFIX="$(brew --prefix openssl 2>/dev/null || true)"
        if [ -d "$SSL_PREFIX/include" ]; then
            SSL_INCLUDE="-I$SSL_PREFIX/include"
        fi
    fi
    if [ -z "$SSL_INCLUDE" ] && [ -d /usr/include/openssl ]; then
        SSL_INCLUDE=""  # system path, no flag needed
    fi
    if [ -z "$SSL_INCLUDE" ] && [ -d /usr/local/include/openssl ]; then
        SSL_INCLUDE="-I/usr/local/include"
    fi

    # shellcheck disable=SC2086
    clang -c -O1 -w $SSL_INCLUDE "$C_SRC" -o rockit_runtime.o

    echo "Built rockit_runtime.o from C runtime"
fi

# Copy to parent directory for Stage 0 discovery
cp rockit_runtime.o "$RUNTIME_DIR/rockit_runtime.o"

echo "Runtime ready: $RUNTIME_DIR/rockit_runtime.o"
