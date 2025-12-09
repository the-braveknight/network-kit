//
//  UserAgent.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A User-Agent header.
///
/// ## Usage
///
/// ```swift
/// Get<User>("users")
///     .headers {
///         UserAgent("MyApp/1.0")
///     }
/// ```
public struct UserAgent: HTTPHeader {
    public let name: HTTPField.Name = .userAgent
    public let value: String

    public init(_ value: String) {
        self.value = value
    }
}
