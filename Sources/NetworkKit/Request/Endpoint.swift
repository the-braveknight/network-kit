//
//  Endpoint.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/29/22.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

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
///             .headers {
///                 Accept(.json)
///             }
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

    /// Builds a URLRequest from this endpoint and a base URL.
    ///
    /// - Parameter baseURL: The base URL to construct the full request URL
    /// - Returns: A configured URLRequest
    public func urlRequest(baseURL: URL) throws -> URLRequest {
        try request.urlRequest(baseURL: baseURL)
    }
}

// MARK: - HTTPService Extension for Endpoint

extension HTTPService {
    /// Loads an endpoint and returns the decoded response.
    ///
    /// - Parameter endpoint: The endpoint to load
    /// - Returns: An ``HTTPResponse`` containing the decoded body and HTTP metadata
    public func load<E: Endpoint>(_ endpoint: E) async throws -> HTTPResponse<E.Response> {
        try await load(endpoint.request)
    }
}
