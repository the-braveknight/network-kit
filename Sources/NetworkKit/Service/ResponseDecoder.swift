//
//  Decoder.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

/// A protocol for types that can decode `Data` into `Decodable` types.
///
/// This protocol abstracts the decoding mechanism, allowing you to use
/// `JSONDecoder`, `PropertyListDecoder`, or any custom decoder with ``HTTPService``.
public protocol ResponseDecoder: Sendable {
    /// Decodes a value of the specified type from the given data.
    ///
    /// - Parameters:
    ///   - type: The type to decode
    ///   - data: The data to decode from
    /// - Returns: The decoded value
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

// MARK: - JSONDecoder Conformance

extension JSONDecoder: ResponseDecoder {}
