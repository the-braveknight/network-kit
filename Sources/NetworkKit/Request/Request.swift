//
//  Request.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// The base protocol for all HTTP network requests.
///
/// `Request` defines the structure and behavior for making HTTP requests in a type-safe, composable way.
/// Rather than conforming to this protocol directly, you typically use the concrete request types like
/// ``Get``, ``Post``, ``Put``, ``Patch``, or ``Delete``.
///
/// ## Usage
///
/// ```swift
/// // Create a GET request with path components
/// let getUserRequest = Get<User>("/users/42")
///
/// // Build a POST request with headers, query items, and body
/// let createUserRequest = Post<User>("/users")
///     .header(.authorization, "Bearer token123")
///     .header(.contentType, "application/json")
///     .header(.accept, "application/json")
///     .queries {
///         Query(name: "notify", value: "true")
///     }
///     .body(CreateUserInput(name: "John Doe", email: "john@example.com"))
/// ```
public protocol Request<ResponseBody>: Identifiable, Sendable {
    /// The type of the decoded response body this request expects.
    associatedtype ResponseBody: Decodable & Sendable

    /// A unique identifier for this request instance.
    ///
    /// Each request has a unique ID that can be used for tracking, logging, or request management.
    var id: UUID { get }

    /// The HTTP method for this request (e.g., GET, POST, PUT, DELETE).
    var method: HTTPRequest.Method { get }

    /// The path components that make up the request URL path.
    ///
    /// These components are joined with "/" to form the request path. For example,
    /// `["users", "42", "profile"]` becomes `/users/42/profile`.
    var pathComponents: [String] { get }

    /// The configuration components for this request.
    var components: RequestComponents { get set }

    /// Creates a request with the specified path components.
    init(_ pathComponents: String...)
}
