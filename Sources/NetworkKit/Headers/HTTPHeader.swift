//
//  HTTPHeader.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A protocol for type-safe HTTP header definitions.
///
/// Conforming types provide a header name and value that can be applied to requests.
///
/// ## Example
///
/// ```swift
/// struct CustomHeader: HTTPHeader {
///     let name: HTTPField.Name = .init("X-Custom")!
///     let value: String
/// }
/// ```
public protocol HTTPHeader: Sendable {
    /// The header field name.
    var name: HTTPField.Name { get }

    /// The header field value.
    var value: String { get }
}
