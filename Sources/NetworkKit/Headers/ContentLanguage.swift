//
//  ContentLanguage.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A Content-Language header for specifying the language of the request body.
///
/// ## Usage
///
/// ```swift
/// Post<User>("users")
///     .headers {
///         ContentLanguage(.english)
///     }
/// ```
public struct ContentLanguage: HTTPHeader {
    public let name: HTTPField.Name = .contentLanguage
    public let value: String

    public init(_ language: Language) {
        self.value = language.rawValue
    }

    public init(_ rawValue: String) {
        self.value = rawValue
    }
}
