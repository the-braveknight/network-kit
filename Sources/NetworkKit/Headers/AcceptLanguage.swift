//
//  AcceptLanguage.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// An Accept-Language header for specifying preferred response languages.
///
/// ## Usage
///
/// ```swift
/// Get<User>("users")
///     .headers {
///         AcceptLanguage(.english)
///         AcceptLanguage(.german, quality: 0.8)
///     }
/// ```
public struct AcceptLanguage: HTTPHeader {
    public let name: HTTPField.Name = .acceptLanguage
    public let value: String

    public init(_ language: Language, quality: Double? = nil) {
        if let quality {
            self.value = "\(language.rawValue);q=\(quality)"
        } else {
            self.value = language.rawValue
        }
    }

    public init(_ rawValue: String) {
        self.value = rawValue
    }
}
