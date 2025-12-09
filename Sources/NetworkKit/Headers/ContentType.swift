//
//  ContentType.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A Content-Type header with common MIME types.
///
/// ## Usage
///
/// ```swift
/// Post<User>("users")
///     .headers {
///         ContentType(.json)
///     }
/// ```
public struct ContentType: HTTPHeader {
    public let name: HTTPField.Name = .contentType
    public let value: String

    public init(_ mimeType: MIMEType) {
        self.value = mimeType.rawValue
    }

    public init(_ rawValue: String) {
        self.value = rawValue
    }
}

/// An Accept header with common MIME types.
///
/// ## Usage
///
/// ```swift
/// Get<User>("users")
///     .headers {
///         Accept(.json)
///     }
/// ```
public struct Accept: HTTPHeader {
    public let name: HTTPField.Name = .accept
    public let value: String

    public init(_ mimeType: MIMEType) {
        self.value = mimeType.rawValue
    }

    public init(_ rawValue: String) {
        self.value = rawValue
    }
}

/// Common MIME types for HTTP headers.
public struct MIMEType: RawRepresentable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    // MARK: - Application Types

    public static let json: MIMEType = "application/json"
    public static let xml: MIMEType = "application/xml"
    public static let pdf: MIMEType = "application/pdf"
    public static let zip: MIMEType = "application/zip"
    public static let octetStream: MIMEType = "application/octet-stream"
    public static let formURLEncoded: MIMEType = "application/x-www-form-urlencoded"

    // MARK: - Text Types

    public static let text: MIMEType = "text/plain"
    public static let html: MIMEType = "text/html"
    public static let css: MIMEType = "text/css"
    public static let javascript: MIMEType = "text/javascript"
    public static let csv: MIMEType = "text/csv"

    // MARK: - Image Types

    public static let png: MIMEType = "image/png"
    public static let jpeg: MIMEType = "image/jpeg"
    public static let gif: MIMEType = "image/gif"
    public static let webp: MIMEType = "image/webp"
    public static let svg: MIMEType = "image/svg+xml"

    // MARK: - Multipart Types

    public static let formData: MIMEType = "multipart/form-data"
}
