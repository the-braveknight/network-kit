//
//  RequestComponents.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A container for the configurable components of an HTTP request.
///
/// `RequestComponents` holds all the configuration data needed to construct a complete HTTP request,
/// including headers, query parameters, body data, timeout settings, and other request options.
public struct RequestComponents: Sendable {
    /// The HTTP headers to include in the request.
    public var headers: [any HTTPHeader]

    /// The query parameters to append to the request URL.
    public var queryItems: [Query]

    /// The body data for the request.
    public var body: Data?

    /// The timeout interval for the request in seconds.
    public var timeout: TimeInterval

    /// The cache policy for the request.
    public var cachePolicy: URLRequest.CachePolicy

    /// Whether the request can use cellular network access.
    public var allowsCellularAccess: Bool

    /// Creates a new request components instance with the specified configuration.
    public init(
        queryItems: [Query] = [],
        body: Data? = nil,
        timeout: TimeInterval = 60,
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        allowsCellularAccess: Bool = true
    ) {
        self.headers = []
        self.queryItems = queryItems
        self.body = body
        self.timeout = timeout
        self.cachePolicy = cachePolicy
        self.allowsCellularAccess = allowsCellularAccess
    }
}
