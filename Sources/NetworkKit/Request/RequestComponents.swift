//
//  RequestComponents.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A container for the configurable components of an HTTP request.
///
/// `RequestComponents` holds all the configuration data needed to construct a complete HTTP request,
/// including headers, query parameters, body data, and timeout settings.
public struct RequestComponents: Sendable {
    /// The HTTP header fields to include in the request.
    public var headerFields: HTTPFields

    /// The query parameters to append to the request URL.
    public var queryItems: [Query]

    /// The body data for the request.
    public var body: Data?

    /// The timeout interval for the request in seconds.
    public var timeout: TimeInterval

    /// Creates a new request components instance with the specified configuration.
    public init(
        headerFields: HTTPFields = HTTPFields(),
        queryItems: [Query] = [],
        body: Data? = nil,
        timeout: TimeInterval = 60
    ) {
        self.headerFields = headerFields
        self.queryItems = queryItems
        self.body = body
        self.timeout = timeout
    }
}

/// A URL query parameter.
public struct Query: Sendable {
    public let name: String
    public let value: String?

    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}
