//
//  HTTPHeader.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 8/13/22.
//

import Foundation

/// A protocol representing an HTTP header field.
public protocol HTTPHeader: Sendable {
    /// The header field name (e.g., "Content-Type", "Authorization").
    var field: String { get }

    /// The header value.
    var value: String { get }
}

extension HTTPHeader {
    public var description: String {
        "\(field): \(value)"
    }
}
