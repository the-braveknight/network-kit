//
//  Query.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 12/19/24.
//

/// A URL query parameter.
public struct Query: Sendable {
    public let name: String
    public let value: String?

    public init(name: String, value: String?) {
        self.name = name
        self.value = value
    }
}
