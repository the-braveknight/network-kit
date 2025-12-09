//
//  CacheControl.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import HTTPTypes

/// A Cache-Control header.
public struct CacheControl: HTTPHeader {
    public let name: HTTPField.Name = .cacheControl
    public let value: String

    public init(_ directive: Directive) {
        self.value = directive.rawValue
    }

    public init(_ rawValue: String) {
        self.value = rawValue
    }

    public struct Directive: RawRepresentable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let noCache = Directive(rawValue: "no-cache")
        public static let noStore = Directive(rawValue: "no-store")
        public static let mustRevalidate = Directive(rawValue: "must-revalidate")

        public static func maxAge(_ seconds: Int) -> Directive {
            Directive(rawValue: "max-age=\(seconds)")
        }
    }
}
