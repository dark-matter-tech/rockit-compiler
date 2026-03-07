# Launchpad — Rockit Standard Library

The standard library for the [Rockit](https://github.com/dark-matter-tech) programming language. 15 modules covering core utilities, file I/O, networking, encoding, testing, and time.

## Usage

Import modules with dot-separated paths:

```kotlin
import rockit.encoding.json
import rockit.core.collections
import rockit.networking.http
import rockit.testing.probe
```

## Modules

| Module | Import | Standard | Description |
|--------|--------|----------|-------------|
| Collections | `rockit.core.collections` | — | List map, filter, fold, sort, zip, flatten, distinct |
| Math | `rockit.core.math` | — | Integer/float math, trig, gcd, lcm, constants |
| Strings | `rockit.core.strings` | — | Pad, repeat, join, split, replace, truncate |
| Result | `rockit.core.result` | — | Result type (Success/Failure) for error handling |
| UUID | `rockit.core.uuid` | RFC 9562 | UUID v4 random generation |
| Base64 | `rockit.encoding.base64` | RFC 4648 | Base64 encode/decode |
| JSON | `rockit.encoding.json` | RFC 8259 | JSON parse, stringify, pretty-print, auto-wrap |
| XML | `rockit.encoding.xml` | W3C XML 1.0 | XML parsing, generation, JSON bridge |
| File I/O | `rockit.filesystem.file` | — | Read, write, exists, delete files |
| Path | `rockit.filesystem.path` | — | Join, dir, base, ext, normalize paths |
| HTTP | `rockit.networking.http` | RFC 9110 | HTTP/1.1 client (GET/POST/PUT/DELETE, HTTPS via curl) |
| URL | `rockit.networking.url` | RFC 3986 | URL parsing, percent-encoding, query parameters |
| WebSocket | `rockit.networking.websocket` | RFC 6455 | WebSocket client with frame encoding |
| Probe | `rockit.testing.probe` | — | Test assertions for `@Test` annotated functions |
| DateTime | `rockit.time.datetime` | ISO 8601 | Date/time formatting, epoch conversion, leap years |

## Installation

The standard library ships with Rockit. When building the compiler from source, launchpad is included as a git submodule at `RockitCompiler/self-hosted-rockit/stdlib`.

```bash
git clone --recurse-submodules https://github.com/dark-matter-tech/moon.git
```

## Structure

```
rockit/
├── core/
│   ├── collections.rok    # List map/filter/fold/sort/zip/flatten
│   ├── math.rok           # Integer & float math, trig, constants
│   ├── strings.rok        # Pad, repeat, join, split, replace
│   ├── result.rok         # Result type (Success/Failure)
│   └── uuid.rok           # UUID v4 generation
├── encoding/
│   ├── base64.rok         # Base64 encode/decode (RFC 4648)
│   ├── json.rok           # JSON encoder/decoder (RFC 8259)
│   └── xml.rok            # XML parser/generator (W3C XML 1.0)
├── filesystem/
│   ├── file.rok           # File I/O wrappers
│   └── path.rok           # Path join/dir/base/ext/normalize
├── networking/
│   ├── http.rok           # HTTP/1.1 client (RFC 9110)
│   ├── url.rok            # URL parser and encoder (RFC 3986)
│   └── websocket.rok      # WebSocket client (RFC 6455)
├── testing/
│   └── probe.rok          # Probe test framework (20+ assertions)
└── time/
    └── datetime.rok       # Date/time utilities (ISO 8601)
tests/
├── core/                  # Tests for core modules
├── encoding/              # Tests for encoding modules
├── filesystem/            # Tests for filesystem modules
├── networking/            # Tests for networking modules
├── testing/               # Tests for testing module
└── time/                  # Tests for time module
```

## Contributing

Contributions are welcome. Please open an issue or pull request on [GitHub](https://github.com/dark-matter-tech/launchpad).

## License

Apache 2.0. Copyright 2026 Dark Matter Tech.
