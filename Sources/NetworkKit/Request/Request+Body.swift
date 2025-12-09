//
//  Request+Body.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

extension Request {
    /// Sets the request body from raw data.
    public func body(_ data: Data) -> Self {
        var copy = self
        copy.components.body = .data(data)
        return copy
    }

    /// Sets the request body with an `Encodable` value.
    ///
    /// The value will be encoded using the service's encoder when the request is loaded.
    /// Automatically sets the `Content-Type` header to `application/json`.
    ///
    /// - Parameter body: The encodable value to use as the request body
    public func body(_ body: some Encodable & Sendable) -> Self {
        var copy = self
        copy.components.body = .encodable { encoder in
            try encoder.encode(body)
        }
        copy.components.headerFields[.contentType] = "application/json"
        return copy
    }

    /// Sets the request body using a result builder.
    ///
    /// The value will be encoded using the service's encoder when the request is loaded.
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
    /// - Parameter builder: A closure that returns an encodable value using result builder syntax
    public func body<Body: Encodable & Sendable>(@HTTPBodyBuilder _ builder: () -> Body?) -> Self {
        var copy = self
        if let body = builder() {
            copy.components.body = .encodable { encoder in
                try encoder.encode(body)
            }
            copy.components.headerFields[.contentType] = "application/json"
        }
        return copy
    }
}

// MARK: - Result Builder

/// Result builder for constructing request bodies in a declarative way.
///
/// `HTTPBodyBuilder` enables the declarative syntax used in the `body(_:)` modifier,
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
    public static func buildBlock<T: Encodable & Sendable>(_ component: T) -> T? {
        component
    }

    public static func buildBlock<T: Encodable & Sendable>(_ component: T?) -> T? {
        component
    }

    public static func buildEither<T: Encodable & Sendable>(first component: T?) -> T? {
        component
    }

    public static func buildEither<T: Encodable & Sendable>(second component: T?) -> T? {
        component
    }

    public static func buildOptional<T: Encodable & Sendable>(_ component: T??) -> T? {
        component.flatMap { $0 }
    }
}
