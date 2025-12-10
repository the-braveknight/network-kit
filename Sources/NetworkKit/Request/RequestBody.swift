//
//  RequestBody.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

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
