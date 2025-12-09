//
//  HTTPService.swift
//  NetworkKitFoundation
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import NetworkKit
import HTTPTypes
import HTTPTypesFoundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The protocol for network service implementations that send HTTP requests.
///
/// `HTTPService` is the main entry point for executing HTTP requests in your application.
/// It provides the base URL, session configuration, and decoding strategy.
///
/// ## Implementation Example
///
/// ```swift
/// struct MyAPIService: HTTPService {
///     let baseURL = URL(string: "https://api.example.com")!
///
///     // session and decoder have default implementations
///     // but you can override them if needed:
///     let session: URLSession = {
///         let configuration = URLSessionConfiguration.default
///         configuration.timeoutIntervalForRequest = 30
///         return URLSession(configuration: configuration)
///     }()
///
///     var decoder: some ResponseDecoder {
///         let decoder = JSONDecoder()
///         decoder.keyDecodingStrategy = .convertFromSnakeCase
///         return decoder
///     }
/// }
/// ```
///
/// ## Usage Example
///
/// ```swift
/// let service = MyAPIService()
///
/// // Load a simple GET request
/// let request = Get<User>("users", "42")
/// let response = try await service.load(request)
/// print("User: \(response.body.name)")
/// ```
public protocol HTTPService: Sendable {
    /// The base URL for all requests sent through this service.
    var baseURL: URL { get }

    /// The `URLSession` used to execute network requests.
    var session: URLSession { get }

    /// The decoder used to decode response bodies.
    associatedtype Decoder: ResponseDecoder = JSONDecoder
    var decoder: Decoder { get }

    /// Loads a request and returns the decoded response.
    ///
    /// - Parameter request: The request to load
    /// - Returns: A ``Response`` containing the decoded body and HTTP metadata
    func load<R: Request>(_ request: R) async throws -> Response<R.ResponseBody>
}

// MARK: - Default Implementations

extension HTTPService {
    public var session: URLSession {
        .shared
    }
}

extension HTTPService where Decoder == JSONDecoder {
    public var decoder: JSONDecoder {
        JSONDecoder()
    }
}

// MARK: - Load Implementation

extension HTTPService {
    public func load<R: Request>(_ request: R) async throws -> Response<R.ResponseBody> {
        let httpRequest = try request.httpRequest(baseURL: baseURL.absoluteString)
        let (data, httpResponse) = try await session.data(for: httpRequest)
        return Response(data: data, status: httpResponse.status, headerFields: httpResponse.headerFields, decoder: decoder)
    }
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
