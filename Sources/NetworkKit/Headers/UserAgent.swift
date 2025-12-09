//
//  UserAgent.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 4/9/24.
//

import Foundation

public struct UserAgent: HTTPHeader {
    public let field: String = "User-Agent"
    public let agent: String

    public var value: String {
        agent
    }

    public init(_ agent: String) {
        self.agent = agent
    }
}
