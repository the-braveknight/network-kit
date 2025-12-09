//
//  NetworkKitError.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// Errors that can occur when using NetworkKit networking.
public enum NetworkKitError: Error {
    /// The URL could not be constructed from the provided components.
    case invalidURL

    /// The server returned an invalid response.
    case invalidResponse

    /// The response body could not be decoded into the expected type.
    ///
    /// The associated `response` contains the raw data and HTTP metadata,
    /// allowing you to inspect what was actually returned.
    case decodingFailed(response: Response<Data>, underlyingError: Error)
}

extension NetworkKitError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL could not be constructed from the provided components."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed(let response, let underlyingError):
            return "Failed to decode response (status \(response.status)): \(underlyingError.localizedDescription)"
        }
    }
}
