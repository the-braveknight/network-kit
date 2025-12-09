//
//  HTTPMethod.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

/// A type-safe representation of HTTP request methods.
public struct HTTPMethod: RawRepresentable, Equatable, Hashable, Sendable {
    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let put = HTTPMethod(rawValue: "PUT")
    public static let patch = HTTPMethod(rawValue: "PATCH")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    public static let head = HTTPMethod(rawValue: "HEAD")
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    public static let connect = HTTPMethod(rawValue: "CONNECT")
    public static let trace = HTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
