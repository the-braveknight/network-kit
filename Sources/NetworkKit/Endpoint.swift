//
//  Endpoint.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/29/22.
//

import HTTPTypes

/// A protocol for defining reusable, type-safe endpoint specifications.
///
/// `Endpoint` wraps a ``Request`` type in a named, reusable definition that can be
/// parameterized with custom properties. This provides a clean abstraction layer
/// that makes your networking code more maintainable and organized.
///
/// ## Usage
///
/// ```swift
/// struct GetUser: Endpoint {
///     let userID: String
///
///     var request: some Request<User> {
///         Get<User>("users", userID)
///             .header(.accept, "application/json")
///     }
/// }
///
/// // Using with HTTPService
/// let endpoint = GetUser(userID: "42")
/// let response = try await service.load(endpoint)
/// print("User: \(response.body.name)")
/// ```
public protocol Endpoint<Response>: Sendable {
    /// The type of the decoded response body this endpoint expects.
    associatedtype Response: Decodable & Sendable

    /// The underlying request type.
    associatedtype RequestType: Request<Response>

    /// The request that defines the actual HTTP request structure.
    var request: RequestType { get }
}

// MARK: - Endpoint Helpers

extension Endpoint {
    /// The expected response type of the underlying request.
    ///
    /// This typealias is a shorthand for `RequestType.ResponseBody`, letting you
    /// refer directly to the return type of the underlying request.
    public typealias ResponseBody = RequestType.ResponseBody
}
