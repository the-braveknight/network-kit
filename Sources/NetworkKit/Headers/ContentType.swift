//
//  ContentType.swift
//  NetworkKit
//
//  Created by Zaid Rahhawi on 2/25/23.
//

import Foundation

public struct ContentType: HTTPHeader {
    public let field: String = "Content-Type"
    public let mimeType: MIMEType

    public var value: String {
        mimeType.value
    }

    public init(_ mimeType: MIMEType) {
        self.mimeType = mimeType
    }
}
