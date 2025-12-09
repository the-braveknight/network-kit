# CLAUDE.md

This file provides guidance for Claude Code when working with the NetworkKit codebase.

## Project Overview

NetworkKit is a type-safe, declarative HTTP networking library for Swift. It provides a clean API for building and executing HTTP requests with compile-time safety for headers, query parameters, and request bodies.

## Build Commands

```bash
# Build the project
swift build

# Run tests
swift test
```

## Architecture

### Core Protocols

- **`Request`** - Base protocol for HTTP requests. Generic over `ResponseBody`. Concrete types: `Get`, `Post`, `Put`, `Patch`, `Delete`, `Head`, `Options`.
- **`Endpoint`** - Wrapper protocol for reusable, parameterized request definitions. Contains a `request` property.
- **`HTTPService`** - Protocol for network services. Provides `baseURL`, `session`, `decoder`, and `load()` methods.
- **`HTTPHeader`** - Protocol for type-safe HTTP headers (`field` and `value` properties).

### Key Types

- **`RequestComponents`** - Container for request configuration (headers, queryItems, body, timeout, cachePolicy).
- **`HTTPResponse<Body>`** - Response wrapper with decoded body and `HTTPURLResponse`.
- **`NetworkKitError`** - Error type with cases: `invalidURL`, `invalidResponse`, `decodingFailed`.

### Type Safety

The library enforces type safety throughout:
- Headers are `[any HTTPHeader]` not `[String: String]`
- Query items are `[Query]` not `[URLQueryItem]`
- MIME types use `MIMEType` enum not raw strings
- Authorization uses `Bearer`, `Basic` types

### Result Builders

- `HTTPHeadersBuilder` - For `.headers { }` modifier
- `QueryBuilder` - For `.queries { }` modifier
- `HTTPBodyBuilder` - For `.body { }` modifier
- `MultiPartFormFieldBuilder` - For `.multiPartForm { }` modifier
- `MIMETypeParameterBuilder` - For MIME type parameters

## Directory Structure

```
Sources/NetworkKit/
├── Body/              # MultiPartForm and related types
├── Headers/           # HTTPHeader protocol and implementations
│   ├── Authorization/ # Bearer, Basic, Auth types
│   └── Language/      # AcceptLanguage, ContentLanguage
├── Request/           # Request, Endpoint, RequestComponents
│   └── Methods/       # Get, Post, Put, Patch, Delete, Head, Options
└── Service/           # HTTPService, HTTPResponse, error types
```

## Code Style

- Use type-safe headers via `HTTPHeader` conforming types
- Prefer `MIMEType.json` over `"application/json"`
- Use result builders for declarative configuration
- Keep `Sendable` conformance on all public types
- Follow existing naming conventions (e.g., `HTTPHeadersBuilder`, `QueryBuilder`)

## Testing

Tests are located in `Tests/`. Run with `swift test`.

## Platform Support

- macOS 13+
- iOS 16+
- watchOS 9+
- tvOS 16+
- Linux (via FoundationNetworking)
