//
//  RequestEncoder.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A protocol for types that can encode `Encodable` values into `Data`.
///
/// This protocol abstracts the encoding mechanism, allowing you to use
/// `JSONEncoder`, `PropertyListEncoder`, or any custom encoder.
public protocol RequestEncoder: Sendable {
    /// Encodes a value into data.
    ///
    /// - Parameter value: The value to encode
    /// - Returns: The encoded data
    func encode<T: Encodable>(_ value: T) throws -> Data
}

// MARK: - JSONEncoder Conformance

extension JSONEncoder: RequestEncoder {}
