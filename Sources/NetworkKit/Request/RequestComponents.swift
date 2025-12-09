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
/// including headers, query parameters, and body data.
public struct RequestComponents: Sendable {
    /// The HTTP header fields to include in the request.
    public var headerFields: HTTPFields

    /// The query parameters to append to the request URL.
    public var queryItems: [Query]

    /// The body content for the request.
    public var body: RequestBody?

    /// The encoder to use for this request. If nil, the service's encoder is used.
    public var encoder: (any RequestEncoder)?

    /// The decoder to use for this request. If nil, the service's decoder is used.
    public var decoder: (any ResponseDecoder)?

    /// Creates a new request components instance with the specified configuration.
    public init(
        headerFields: HTTPFields = HTTPFields(),
        queryItems: [Query] = [],
        body: RequestBody? = nil,
        encoder: (any RequestEncoder)? = nil,
        decoder: (any ResponseDecoder)? = nil
    ) {
        self.headerFields = headerFields
        self.queryItems = queryItems
        self.body = body
        self.encoder = encoder
        self.decoder = decoder
    }
}

/// Represents the body content of an HTTP request.
public enum RequestBody: Sendable {
    /// Raw data body (already encoded or binary data).
    case data(Data)

    /// An encodable value that will be encoded using the service's encoder.
    case encodable(@Sendable (any RequestEncoder) throws -> Data)

    /// Encodes the body using the provided encoder.
    ///
    /// - Parameter encoder: The encoder to use for encodable bodies
    /// - Returns: The encoded data
    public func encode(using encoder: some RequestEncoder) throws -> Data {
        switch self {
        case .data(let data):
            return data
        case .encodable(let encode):
            return try encode(encoder)
        }
    }
}
