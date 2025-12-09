# NetworkKit

A type-safe, declarative HTTP networking library for Swift.

## Features

- Type-safe request building with `Request` and `Endpoint` protocols
- Declarative API using result builders for headers, queries, and body
- Built-in HTTP method types: `Get`, `Post`, `Put`, `Patch`, `Delete`, `Head`, `Options`
- Type-safe HTTP headers with `MIMEType`, `Authorization`, `ContentType`, etc.
- Multipart form data support
- Automatic JSON encoding/decoding
- Linux support via FoundationNetworking

## Installation

Add NetworkKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/the-braveknight/NetworkKit.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define your service

```swift
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
    .headers {
        Authorization(.bearer(token: "token123"))
        Accept(.json)
    }
    .body(CreateUserInput(name: "John", email: "john@example.com"))
```

### 3. Load the request

```swift
let service = MyAPIService()
let response = try await service.load(request)
print(response.body.name)
```

## Endpoints

For reusable, parameterized requests, define an `Endpoint`:

```swift
struct GetUser: Endpoint {
    let userID: String

    var request: some Request<User> {
        Get<User>("users", userID)
            .headers {
                Accept(.json)
            }
    }
}

// Usage
let endpoint = GetUser(userID: "42")
let response = try await service.load(endpoint)
```

## Type-Safe Headers

NetworkKit provides type-safe headers:

```swift
.headers {
    // Authorization
    Authorization(.bearer(token: "token"))
    Authorization(.basic(username: "user", password: "pass"))

    // Content types
    ContentType(.json)
    Accept(.json)

    // Language
    AcceptLanguage(.en, .ar(quality: 0.8))
    ContentLanguage(.en)

    // Others
    UserAgent("MyApp/1.0")
    ContentLength(1024)
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
            .contentDisposition(.formData, .name("message"))

        File(data: imageData)
            .contentDisposition(.formData, .name("file"), .filename("image.png"))
            .contentType(.png)
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
        print("Status: \(response.statusCode)")
        print("Error: \(underlyingError)")
    }
}
```

## License

NetworkKit is released under the MIT License.
