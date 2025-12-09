# CLAUDE.md

This file provides guidance for Claude Code when working with the NetworkKit codebase.

## Project Overview

NetworkKit is a type-safe, declarative HTTP networking library for Swift built on Apple's `swift-http-types`. It provides a clean API for building HTTP requests with compile-time safety. The library is split into two modules:

- **NetworkKit** - Core module for building `HTTPRequest` objects (no URLSession dependency)
- **NetworkKitFoundation** - Driver module for executing requests via URLSession

## Build Commands

```bash
# Build the project
swift build

# Run tests
swift test
```

## Architecture

### Core Protocols (NetworkKit)

- **`Request`** - Base protocol for HTTP requests. Generic over `ResponseBody`. Concrete types: `Get`, `Post`, `Put`, `Patch`, `Delete`, `Head`, `Options`.
- **`Endpoint`** - Wrapper protocol for reusable, parameterized request definitions. Contains a `request` property.
- **`HTTPHeader`** - Protocol for type-safe header definitions with `name` and `value`.

### Driver Protocol (NetworkKitFoundation)

- **`HTTPService`** - Protocol for network services. Provides `baseURL` (as `URL`), `session`, `decoder`, and `load()` methods.

### Key Types

- **`RequestComponents`** - Container for request configuration (headerFields as `HTTPFields`, queryItems, body).
- **`Response<Body>`** - Response wrapper with decoded body, `HTTPResponse.Status`, and `HTTPFields`.
- Uses `HTTPRequest`, `HTTPResponse`, `HTTPFields` from `swift-http-types`.

### Headers

Two approaches for setting headers:

**Simple headers using `HTTPField.Name`:**

```swift
Get<User>("users")
    .header(.authorization, "Bearer token")
    .header(.accept, "application/json")
```

**Type-safe headers using `HTTPHeader` protocol:**

```swift
Get<User>("users")
    .headers {
        Authorization(.bearer(token: "my-token"))
        Accept(.json)
        ContentType(.json)
        UserAgent("MyApp/1.0")
        AcceptLanguage(.english)
    }
```

**Built-in header types:**
- `Authorization` - With extensible `Scheme` protocol: `Bearer`, `Basic`, or custom
- `Accept` - Accept header with `MIMEType`
- `ContentType` - Content-Type header with `MIMEType`
- `UserAgent` - User-Agent header
- `AcceptLanguage` - Accept-Language with `Language` and optional quality
- `ContentLanguage` - Content-Language header
- `ContentLength` - Content-Length header
- `CacheControl` - Cache-Control with `Directive`

### Result Builders

- `QueryBuilder` - For `.queries { }` modifier
- `HTTPBodyBuilder` - For `.body { }` modifier
- `HTTPHeadersBuilder` - For `.headers { }` modifier

## Directory Structure

```
Sources/
├── NetworkKit/                    # Core module
│   ├── Endpoint.swift             # Endpoint protocol
│   ├── Headers/                   # HTTPHeader protocol and implementations
│   │   ├── HTTPHeader.swift
│   │   ├── Authorization.swift    # Authorization with Scheme protocol (Bearer, Basic)
│   │   ├── ContentType.swift      # ContentType, Accept, MIMEType
│   │   ├── AcceptLanguage.swift
│   │   ├── ContentLanguage.swift
│   │   ├── Language.swift
│   │   ├── UserAgent.swift
│   │   ├── ContentLength.swift
│   │   └── CacheControl.swift
│   ├── Request/                   # Request protocol and components
│   │   ├── Request.swift
│   │   ├── Request+Headers.swift  # header(), headers(), HTTPHeadersBuilder
│   │   ├── Request+Query.swift    # query(), queries(), QueryBuilder
│   │   ├── Request+Body.swift     # body(), HTTPBodyBuilder
│   │   ├── RequestComponents.swift
│   │   ├── RequestEncoder.swift
│   │   └── Methods/
│   │       ├── Get.swift
│   │       ├── Post.swift
│   │       ├── Put.swift
│   │       ├── Patch.swift
│   │       ├── Delete.swift
│   │       ├── Head.swift
│   │       └── Options.swift
│   └── Response/
│       ├── Response.swift
│       └── ResponseDecoder.swift
└── NetworkKitFoundation/
    └── HTTPService.swift

Tests/
├── NetworkKitTests/
└── NetworkKitFoundationTests/
```

## Code Style

- Use `HTTPField.Name` for simple header names (e.g., `.authorization`, `.contentType`)
- Use `HTTPHeader` types with `headers { }` builder for type-safe declarative headers
- Use result builders for declarative configuration
- Keep `Sendable` conformance on all public types
- Use `URL` for `baseURL` in `HTTPService`

## Testing

Tests are in `Tests/NetworkKitTests/` and `Tests/NetworkKitFoundationTests/`. Run with `swift test`.

## Platform Support

- macOS 13+
- iOS 16+
- watchOS 9+
- tvOS 16+
- Linux (via FoundationNetworking)

## Dependencies

- [swift-http-types](https://github.com/apple/swift-http-types) - Core HTTP types (`HTTPRequest`, `HTTPResponse`, `HTTPFields`)
