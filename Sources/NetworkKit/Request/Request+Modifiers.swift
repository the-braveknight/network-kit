//
//  Request+Modifiers.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Headers Modifier

extension Request {
    /// Adds HTTP headers to the request using a result builder.
    ///
    /// ```swift
    /// Get<User>("users")
    ///     .headers {
    ///         Authorization(Bearer(token: "token"))
    ///         Accept(.json)
    ///     }
    /// ```
    public func headers(@HTTPHeadersBuilder _ builder: () -> [any HTTPHeader]) -> Self {
        var copy = self
        copy.components.headers.append(contentsOf: builder())
        return copy
    }

    /// Adds a single header to the request.
    public func header(_ header: some HTTPHeader) -> Self {
        var copy = self
        copy.components.headers.append(header)
        return copy
    }

    /// Sets the Authorization header.
    public func authorization(_ auth: some Auth) -> Self {
        header(Authorization(auth))
    }

    /// Sets the Content-Type header.
    public func contentType(_ mimeType: MIMEType) -> Self {
        header(ContentType(mimeType))
    }

    /// Sets the Accept header.
    public func accept(_ mimeType: MIMEType) -> Self {
        header(Accept(mimeType))
    }

    /// Sets the User-Agent header.
    public func userAgent(_ value: String) -> Self {
        header(UserAgent(value))
    }
}

// MARK: - Query Modifier

extension Request {
    /// Adds query parameters to the request URL using a result builder.
    ///
    /// ```swift
    /// Get<[User]>("users")
    ///     .queries {
    ///         Query(name: "page", value: "1")
    ///         Query(name: "limit", value: "20")
    ///     }
    /// ```
    public func queries(@QueryBuilder _ builder: () -> [Query]) -> Self {
        var copy = self
        copy.components.queryItems.append(contentsOf: builder())
        return copy
    }

    /// Adds a single query parameter to the request.
    public func query(_ query: Query) -> Self {
        var copy = self
        copy.components.queryItems.append(query)
        return copy
    }
}

// MARK: - Body Modifiers

extension Request {
    /// Sets the request body from raw data.
    public func body(_ data: Data) -> Self {
        var copy = self
        copy.components.body = data
        return copy
    }

    /// Sets the request body by encoding an `Encodable` value.
    ///
    /// Automatically sets the `Content-Type` header to `application/json`.
    ///
    /// - Parameters:
    ///   - body: The encodable value to use as the request body
    ///   - encoder: The encoder to use (defaults to `JSONEncoder()`)
    public func body<Body: Encodable>(_ body: Body, encoder: some RequestEncoder = JSONEncoder()) -> Self {
        var copy = self
        copy.components.body = try? encoder.encode(body)
        copy.components.headers.append(ContentType(.json))
        return copy
    }

    /// Sets the request body using a result builder.
    ///
    /// Automatically sets the `Content-Type` header to `application/json`.
    ///
    /// ```swift
    /// Post<User>("users")
    ///     .body {
    ///         if useDetailed {
    ///             DetailedInput(name: "John", age: 30)
    ///         } else {
    ///             SimpleInput(name: "John")
    ///         }
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - encoder: The encoder to use (defaults to `JSONEncoder()`)
    ///   - builder: A closure that returns an encodable value using result builder syntax
    public func body(encoder: some RequestEncoder = JSONEncoder(), @HTTPBodyBuilder _ builder: () -> (any Encodable)?) -> Self {
        var copy = self
        if let body = builder() {
            if let data = body as? Data {
                copy.components.body = data
            } else {
                copy.components.body = try? encoder.encode(body)
            }
            copy.components.headers.append(ContentType(.json))
        }
        return copy
    }
}

// MARK: - Timeout Modifier

extension Request {
    /// Sets the timeout interval for the request.
    ///
    /// - Parameter interval: The timeout interval in seconds (default: 60 seconds)
    public func timeout(_ interval: TimeInterval) -> Self {
        var copy = self
        copy.components.timeout = interval
        return copy
    }
}

// MARK: - Cache Policy Modifier

extension Request {
    /// Sets the cache policy for the request.
    public func cachePolicy(_ policy: URLRequest.CachePolicy) -> Self {
        var copy = self
        copy.components.cachePolicy = policy
        return copy
    }
}

// MARK: - Cellular Access Modifier

extension Request {
    /// Sets whether the request can use cellular network access.
    public func allowsCellularAccess(_ allowed: Bool) -> Self {
        var copy = self
        copy.components.allowsCellularAccess = allowed
        return copy
    }
}

// MARK: - Result Builders

/// Result builder for constructing arrays of HTTP headers.
@resultBuilder
public struct HTTPHeadersBuilder {
    public static func buildExpression(_ header: some HTTPHeader) -> [any HTTPHeader] {
        [header]
    }

    public static func buildOptional(_ component: [any HTTPHeader]?) -> [any HTTPHeader] {
        component ?? []
    }

    public static func buildEither(first component: [any HTTPHeader]) -> [any HTTPHeader] {
        component
    }

    public static func buildEither(second component: [any HTTPHeader]) -> [any HTTPHeader] {
        component
    }

    public static func buildArray(_ components: [[any HTTPHeader]]) -> [any HTTPHeader] {
        components.flatMap { $0 }
    }

    public static func buildBlock(_ components: [any HTTPHeader]...) -> [any HTTPHeader] {
        components.flatMap { $0 }
    }
}

/// Result builder for constructing arrays of query parameters.
@resultBuilder
public struct QueryBuilder {
    public static func buildExpression(_ query: Query) -> [Query] {
        [query]
    }

    public static func buildOptional(_ component: [Query]?) -> [Query] {
        component ?? []
    }

    public static func buildEither(first component: [Query]) -> [Query] {
        component
    }

    public static func buildEither(second component: [Query]) -> [Query] {
        component
    }

    public static func buildArray(_ components: [[Query]]) -> [Query] {
        components.flatMap { $0 }
    }

    public static func buildBlock(_ components: [Query]...) -> [Query] {
        components.flatMap { $0 }
    }
}

/// Result builder for constructing request bodies in a declarative way.
///
/// `HTTPBodyBuilder` enables the declarative syntax used in the `body(encoder:_:)` modifier,
/// allowing you to specify the request body with support for conditionals and optionals.
/// Only a single body value is allowed per request.
///
/// ```swift
/// .body {
///     CreateUserInput(name: "John", email: "john@example.com")
/// }
/// ```
@resultBuilder
public enum HTTPBodyBuilder {
    public static func buildBlock(_ component: (any Encodable)?) -> (any Encodable)? {
        component
    }

    public static func buildExpression(_ expression: (any Encodable)?) -> (any Encodable)? {
        expression
    }

    public static func buildEither(first component: (any Encodable)?) -> (any Encodable)? {
        component
    }

    public static func buildEither(second component: (any Encodable)?) -> (any Encodable)? {
        component
    }

    public static func buildOptional(_ component: (any Encodable)??) -> (any Encodable)? {
        component.flatMap { $0 }
    }

    @available(*, unavailable, message: "Only one Encodable body is allowed in a request.")
    public static func buildBlock(_ components: (any Encodable)?...) -> (any Encodable)? {
        fatalError()
    }
}

// MARK: - Query Type

/// A URL query parameter.
public struct Query: Sendable {
    public let name: String
    public let value: String?

    public var urlQueryItem: URLQueryItem {
        URLQueryItem(name: name, value: value)
    }

    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}
