//
//  Authorization.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 2/25/23.
//

public struct Authorization<A: Auth>: HTTPHeader {
    public let field: String = "Authorization"
    public let auth: A

    public var value: String {
        auth.value
    }

    public init(_ auth: A) {
        self.auth = auth
    }
}
