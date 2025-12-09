//
//  HTTPService.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/10/25.
//

/// The base protocol for network service implementations that execute HTTP requests.
///
/// `HTTPService` defines the core interface for executing HTTP requests in your application.
/// Concrete implementations can use different backends like URLSession, swift-nio, or async-http-client.
///
/// ## Implementation
///
/// To create a concrete implementation, conform to this protocol and implement the `load(_:)` method:
///
/// ```swift
/// struct MyService: HTTPService {
///     var encoder: JSONEncoder {
///         let encoder = JSONEncoder()
///         encoder.keyEncodingStrategy = .convertToSnakeCase
///         return encoder
///     }
///
///     var decoder: JSONDecoder {
///         let decoder = JSONDecoder()
///         decoder.keyDecodingStrategy = .convertFromSnakeCase
///         return decoder
///     }
///
///     func load<R: Request>(_ request: R) async throws -> Response<R.ResponseBody> {
///         // Implementation using your preferred HTTP client
///     }
/// }
/// ```
///
/// ## Usage
///
/// ```swift
/// let service = MyService()
/// let request = Get<User>("/users/42")
/// let response = try await service.load(request)
/// print("User: \(try response.body.name)")
/// ```
public protocol HTTPService: Sendable {
    /// The encoder used to encode request bodies.
    associatedtype Encoder: RequestEncoder
    var encoder: Encoder { get }

    /// The decoder used to decode response bodies.
    associatedtype Decoder: ResponseDecoder
    var decoder: Decoder { get }

    /// Loads a request and returns the decoded response.
    ///
    /// - Parameter request: The request to load
    /// - Returns: A ``Response`` containing the decoded body and HTTP metadata
    func load<R: Request>(_ request: R) async throws -> Response<R.ResponseBody>
}

// MARK: - HTTPService Extension for Endpoint

extension HTTPService {
    /// Loads an endpoint and returns the decoded response.
    ///
    /// - Parameter endpoint: The endpoint to load
    /// - Returns: A ``Response`` containing the decoded body and HTTP metadata
    public func load<E: Endpoint>(_ endpoint: E) async throws -> Response<E.Response> {
        try await load(endpoint.request)
    }
}
