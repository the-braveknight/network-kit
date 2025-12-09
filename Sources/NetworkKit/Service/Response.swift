//
//  Response.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A generic HTTP response container that wraps the decoded response body with HTTP metadata.
public struct Response<Body>: Sendable where Body: Sendable {
    /// The decoded response body.
    public let body: Body

    /// The HTTP status of the response.
    public let status: HTTPResponse.Status

    /// The HTTP headers of the response.
    public let headerFields: HTTPFields

    /// Creates a response with the decoded body, status, and headers.
    public init(body: Body, status: HTTPResponse.Status, headerFields: HTTPFields) {
        self.body = body
        self.status = status
        self.headerFields = headerFields
    }
}
