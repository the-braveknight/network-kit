//
//  HTTPResponse.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A generic HTTP response container that wraps the decoded response body with HTTP metadata.
public struct HTTPResponse<Body>: Sendable where Body: Sendable {
    /// The decoded response body.
    public let body: Body

    /// The original `HTTPURLResponse` from the network request.
    public let originalResponse: HTTPURLResponse

    /// Creates an HTTP response with the decoded body and original HTTP response.
    public init(body: Body, originalResponse: HTTPURLResponse) {
        self.body = body
        self.originalResponse = originalResponse
    }

    /// The HTTP status code of the response (e.g., 200, 404, 500).
    public var statusCode: Int {
        originalResponse.statusCode
    }

    /// The HTTP headers of the response as a string-to-string dictionary.
    public var headers: [String: String] {
        originalResponse.allHeaderFields.reduce(into: [:]) { result, pair in
            if let key = pair.key as? String, let value = pair.value as? String {
                result[key] = value
            }
        }
    }

    /// The category of the HTTP response status code.
    public var status: HTTPResponseStatus {
        switch statusCode {
        case 100...199:
            return .informational
        case 200...299:
            return .success
        case 300...399:
            return .redirection
        case 400...499:
            return .clientError
        case 500...599:
            return .serverError
        default:
            return .unknown
        }
    }
}

/// Categories for HTTP response status codes.
public enum HTTPResponseStatus: Sendable {
    /// Informational responses (100-199).
    case informational
    /// Successful responses (200-299).
    case success
    /// Redirection messages (300-399).
    case redirection
    /// Client error responses (400-499).
    case clientError
    /// Server error responses (500-599).
    case serverError
    /// Status codes outside the standard ranges.
    case unknown
}
