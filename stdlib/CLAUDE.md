# Launchpad — Stdlib Development Guidelines

## Repository

This is the Rockit standard library. It is included as a git submodule in the compiler repo at `RockitCompiler/self-hosted-rockit/stdlib`.

## Module Structure

Every module file must follow this header template:

```
// rockit.<domain>.<module> — <One-line description>
//
// <2-4 sentence description of purpose, use cases, and design decisions.>
//
// Standards: <RFC/ISO reference, or omit if none applies>
//
// Usage:
//   import rockit.<domain>.<module>
//   <2-3 lines of typical usage>

// == Section Name ============================================================
```

## Naming Conventions

- **Directories**: Full words, lowercase (`filesystem/` not `io/`, `networking/` not `net/`)
- **Files**: Full words, lowercase (`websocket.rok` not `ws.rok`)
- **Functions**: camelCase, prefixed with module context (`jsonParse`, `urlEncode`, `httpGet`)
- **Type constants**: UPPER_SNAKE via functions (`JSON_NULL()`, `XML_ELEMENT()`)

## Import Paths

All imports use the pattern `rockit.<domain>.<module>`:

| Domain | Modules |
|--------|---------|
| `core` | collections, math, strings, result, uuid |
| `encoding` | base64, json, xml |
| `filesystem` | file, path |
| `networking` | http, url, websocket |
| `testing` | probe |
| `time` | datetime |

## Error Handling

Use tagged maps for error reporting (consistent with JSON/XML pattern):
- Return a map with `"type"` set to an error constant (e.g., `JSON_ERROR()`, `XML_ERROR()`)
- Check with type-checking functions (e.g., `jsonIsError()`, `xmlIsError()`)

## Code Reuse

- **No inline duplication.** If url.rok has URL parsing, http.rok and websocket.rok must import it.
- **No inline base64.** websocket.rok uses `base64Encode` from rockit.encoding.base64.
- Shared helpers (like `urlToLower`, `urlExtractHost`) live in url.rok.

## Tests

Every module has a corresponding test file in `tests/<domain>/test_<module>.rok`. Tests use:
- `import rockit.testing.probe`
- `@Test` annotation on every test function
- RFC test vectors where applicable (especially Base64 Section 10)

## Standards References

| Module | Standard |
|--------|----------|
| encoding/json | RFC 8259, ECMA-404, ISO/IEC 21778:2017 |
| encoding/xml | W3C XML 1.0 Fifth Edition |
| encoding/base64 | RFC 4648 |
| networking/http | RFC 9110, RFC 9112 |
| networking/url | RFC 3986 |
| networking/websocket | RFC 6455 |
| core/uuid | RFC 9562 |
| time/datetime | ISO 8601:2019, RFC 3339 |
