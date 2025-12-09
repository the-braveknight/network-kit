//
//  LanguagePreference.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

import Foundation

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public struct LanguagePreference: Equatable, Codable, Sendable {
    let language: Locale.Language
    let quality: Double
    
    public init(language: Locale.Language, quality: Double = 1.0) {
        self.language = language
        self.quality = quality
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension LanguagePreference: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        let components = value.split(separator: ";q=", maxSplits: 1, omittingEmptySubsequences: false)
        self.language = Locale.Language(identifier: String(components[0]))
        self.quality = components.indices.contains(1) ? Double(String(components[1])) ?? 1.0 : 1.0
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
extension LanguagePreference: CustomStringConvertible {
    public var description: String {
        let roundedQuality = round(quality * 10) / 10
        if roundedQuality < 1.0 {
            return language.maximalIdentifier + ";q=\(String(format: "%.1f", roundedQuality))"
        }
        
        return language.maximalIdentifier
    }
}

@available(macOS 13, iOS 16, tvOS 16, watchOS 9, *)
public extension LanguagePreference {
    static let enUS: Self = "en-Latn-US"
}
