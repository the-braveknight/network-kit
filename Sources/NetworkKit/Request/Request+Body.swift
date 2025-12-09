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
        copy.components.headerFields[.contentType] = "application/json"
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
            copy.components.headerFields[.contentType] = "application/json"
        }
        return copy
    }
}

// MARK: - Result Builder

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
}
