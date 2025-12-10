//
//  Request+Headers.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

extension Request {
    /// Adds a header field to the request.
    ///
    /// ```swift
    /// Get<User>("users")
    ///     .header(.authorization, "Bearer token")
    ///     .header(.accept, "application/json")
    /// ```
    public func header(_ name: HTTPField.Name, _ value: String) -> Self {
        var copy = self
        copy.components.headerFields[name] = value
        return copy
    }

    /// Adds multiple headers to the request using a result builder.
    ///
    /// ```swift
    /// Get<User>("users")
    ///     .headers {
    ///         Authorization(.bearer(token: "token"))
    ///         Accept(.json)
    ///         ContentType(.json)
    ///     }
    /// ```
    public func headers(@HTTPHeadersBuilder _ builder: () -> [any HTTPHeader]) -> Self {
        var copy = self
        for header in builder() {
            copy.components.headerFields[header.name] = header.value
        }
        return copy
    }
}

// MARK: - Result Builder

/// Result builder for constructing arrays of HTTP headers.
///
/// `HTTPHeadersBuilder` enables the declarative syntax used in the `headers(_:)` modifier.
///
/// ```swift
/// .headers {
///     Authorization(.bearer(token: "token"))
///     Accept(.json)
///     if includeCustomHeader {
///         CustomHeader(name: "X-Custom", value: "value")
///     }
/// }
/// ```
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
