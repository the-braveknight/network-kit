//
//  Response.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation
import HTTPTypes

/// A generic HTTP response container that wraps the decoded response body with HTTP metadata.
public struct Response<Body>: Sendable where Body: Sendable & Decodable {
    /// The raw response data.
    public let data: Data

    /// The HTTP status of the response.
    public let status: HTTPResponse.Status

    /// The HTTP headers of the response.
    public let headerFields: HTTPFields

    /// The decoder used to decode the response body.
    private let decoder: any ResponseDecoder

    /// The decoded response body. Decodes on demand.
    public var body: Body {
        get throws {
            try decoder.decode(Body.self, from: data)
        }
    }

    /// Creates a response with the raw data, status, headers, and decoder.
    public init(data: Data, status: HTTPResponse.Status, headerFields: HTTPFields, decoder: any ResponseDecoder) {
        self.data = data
        self.status = status
        self.headerFields = headerFields
        self.decoder = decoder
    }
}
