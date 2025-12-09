//
//  Language.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

/// Common language tags for HTTP headers.
public struct Language: RawRepresentable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    // MARK: - Common Languages

    public static let english: Language = "en"
    public static let englishUS: Language = "en-US"
    public static let englishGB: Language = "en-GB"
    public static let german: Language = "de"
    public static let french: Language = "fr"
    public static let spanish: Language = "es"
    public static let italian: Language = "it"
    public static let portuguese: Language = "pt"
    public static let dutch: Language = "nl"
    public static let russian: Language = "ru"
    public static let japanese: Language = "ja"
    public static let korean: Language = "ko"
    public static let chinese: Language = "zh"
    public static let chineseSimplified: Language = "zh-Hans"
    public static let chineseTraditional: Language = "zh-Hant"
    public static let arabic: Language = "ar"
}
