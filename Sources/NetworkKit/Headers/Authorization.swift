//
//  Authorization.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// An Authorization header with pluggable authentication schemes.
///
/// ## Usage
///
/// ```swift
/// Get<User>("users")
///     .headers {
///         Authorization(Bearer(token: "my-token"))
///         Authorization(Basic(username: "user", password: "pass"))
///     }
/// ```
public struct Authorization: HTTPHeader {
    public let name: HTTPField.Name = .authorization
    public let value: String

    public init(_ scheme: some Scheme) {
        self.value = scheme.value
    }

    /// A protocol for authentication schemes used in Authorization headers.
    ///
    /// Implement this protocol to create custom authentication schemes.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct APIKey: Authorization.Scheme {
    ///     let key: String
    ///
    ///     var value: String {
    ///         "ApiKey \(key)"
    ///     }
    /// }
    /// ```
    public protocol Scheme: Sendable {
        /// The value to use in the Authorization header.
        var value: String { get }
    }
}

/// Bearer token authentication scheme.
public struct Bearer: Authorization.Scheme {
    public let token: String

    public init(token: String) {
        self.token = token
    }

    public var value: String {
        "Bearer \(token)"
    }
}

/// Basic authentication scheme with username and password.
public struct Basic: Authorization.Scheme {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public var value: String {
        let credentials = "\(username):\(password)"
        let encoded = Data(credentials.utf8).base64EncodedString()
        return "Basic \(encoded)"
    }
}

// MARK: - Dot Syntax Extensions

extension Authorization.Scheme where Self == Bearer {
    /// Bearer token authentication.
    ///
    /// ```swift
    /// Authorization(.bearer(token: "my-token"))
    /// ```
    public static func bearer(token: String) -> Self {
        Bearer(token: token)
    }
}

extension Authorization.Scheme where Self == Basic {
    /// Basic authentication with username and password.
    ///
    /// ```swift
    /// Authorization(.basic(username: "user", password: "pass"))
    /// ```
    public static func basic(username: String, password: String) -> Self {
        Basic(username: username, password: password)
    }
}
