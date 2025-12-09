# NetworkKit

A type-safe, declarative HTTP networking library for Swift built on [swift-http-types](https://github.com/apple/swift-http-types).

## Features

- Type-safe request building with `Request` and `Endpoint` protocols
- Declarative API using result builders for headers, queries, and body
- Built-in HTTP method types: `Get`, `Post`, `Put`, `Patch`, `Delete`, `Head`, `Options`
- HTTP headers via `HTTPField.Name` from swift-http-types
- Multipart form data support
- Automatic JSON encoding/decoding
- Modular design: Core + Foundation driver
- Linux support via FoundationNetworking

## Installation

Add NetworkKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/the-braveknight/NetworkKit.git", from: "2.0.0")
]
```

Add the targets you need:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        "NetworkKit",           // Core request building
        "NetworkKitFoundation", // URLSession execution
    ]
)
```

## Quick Start

### 1. Define your service

```swift
import NetworkKit
import NetworkKitFoundation

struct MyAPIService: HTTPService {
    let baseURL = URL(string: "https://api.example.com")!
}
```

### 2. Create a request

```swift
// Simple GET request
let request = Get<User>("users", "42")

// POST request with headers and body
let request = Post<User>("users")
    .header(.authorization, "Bearer token123")
    .header(.contentType, "application/json")
    .body(CreateUserInput(name: "John", email: "john@example.com"))
```

### 3. Load the request

```swift
let service = MyAPIService()
let response = try await service.load(request)
print(response.body.name)
print(response.status) // HTTPResponse.Status
```

## Endpoints

For reusable, parameterized requests, define an `Endpoint`:

```swift
struct GetUser: Endpoint {
    let userID: String

    var request: some Request<User> {
        Get<User>("users", userID)
            .header(.accept, "application/json")
    }
}

// Usage
let endpoint = GetUser(userID: "42")
let response = try await service.load(endpoint)
```

## Headers

### Simple Headers

Use `HTTPField.Name` from swift-http-types:

```swift
Get<User>("users")
    .header(.authorization, "Bearer token")
    .header(.accept, "application/json")
    .header(.contentType, "application/json")
```

### Type-Safe Headers

Use the built-in header types with the `headers` result builder:

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

### Available Header Types

- `Authorization` - With extensible schemes: `.bearer(token:)`, `.basic(username:password:)`
- `Accept` - Accept header with `MIMEType`
- `ContentType` - Content-Type header with `MIMEType`
- `UserAgent` - User-Agent header
- `AcceptLanguage` - Accept-Language header with `Language` and optional quality
- `ContentLanguage` - Content-Language header
- `ContentLength` - Content-Length header
- `CacheControl` - Cache-Control header with directives

### Custom Authorization Schemes

Implement the `Authorization.Scheme` protocol:

```swift
struct APIKey: Authorization.Scheme {
    let key: String

    var value: String {
        "ApiKey \(key)"
    }
}

// Usage
Get<User>("users")
    .headers {
        Authorization(APIKey(key: "secret"))
    }
```

## Query Parameters

```swift
Get<[User]>("users")
    .queries {
        Query(name: "page", value: "1")
        Query(name: "limit", value: "20")

        if let search = searchTerm {
            Query(name: "q", value: search)
        }
    }
```

## Request Body

```swift
// Direct value
Post<User>("users")
    .body(CreateUserInput(name: "John"))

// With result builder (supports conditionals)
Post<User>("users")
    .body {
        if useDetailed {
            DetailedInput(name: "John", age: 30)
        } else {
            SimpleInput(name: "John")
        }
    }

// Custom encoder
let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase

Post<User>("users")
    .body(input, encoder: encoder)
```

## Multipart Form Data

```swift
Post<UploadResponse>("upload")
    .multiPartForm(boundary: "Boundary-\(UUID().uuidString)") {
        Text("Hello")
            .contentDisposition(name: "message")

        File(data: imageData)
            .contentDisposition(name: "file", filename: "image.png")
            .contentType("image/png")
    }
```

## Custom Decoder

```swift
struct MyAPIService: HTTPService {
    let baseURL = URL(string: "https://api.example.com")!

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
```

## Error Handling

```swift
do {
    let response = try await service.load(request)
} catch let error as NetworkKitError {
    switch error {
    case .invalidURL:
        print("Invalid URL")
    case .invalidResponse:
        print("Invalid response")
    case .decodingFailed(let response, let underlyingError):
        print("Status: \(response.status)")
        print("Error: \(underlyingError)")
    }
}
```

## Architecture

NetworkKit is split into two modules:

- **NetworkKit** - Core module for building `HTTPRequest` objects from swift-http-types. No URLSession dependency.
- **NetworkKitFoundation** - Driver module that executes requests via URLSession using HTTPTypesFoundation.

This design allows for future drivers (e.g., async-http-client for swift-nio).

## License

NetworkKit is released under the MIT License.
